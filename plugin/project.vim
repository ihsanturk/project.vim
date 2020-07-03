" Maintainer: ihsan
" Mail: ihsanl at pm dot me
" Last Change: 2020 Jul 03 14:54:20, @1593777244

" Limitation1: user can't create a project named: "new"
"
" Fix for Limitation1:
" TODO: Make first argument as a command and complete with other commands like
" new,rename,cd,delete, check this link for argument specific completions:
" https://stackoverflow.com/questions/6937984/is-there-a-way-to-make-use-of-two-custom-complete-functions-in-vimscript

let g:projectdir = '~/project/'

" Add these too: [sh|py|c|cpp|rs|hs]
let g:projecttemplate = {
	\ 'sh': $pwd.'/templates/shell',
	\ 'rs': $pwd.'/templates/rust',
\}

func! s:usage()
	call s:warn(':Project [new] <projectname> [template]')
endf

func! s:ProjectComplete(arglead,L,P)
	return add(s:filter(systemlist('ls '.g:projectdir), a:arglead), 'new')
endf

command! -nargs=* -complete=customlist,s:ProjectComplete Project
		\ call s:cmd(<f-args>)

func! s:cmd(...) abort
	let args = copy(a:000)
	if len(args) < 1
		call s:usage() | return
	else
		let l:projectname = args[0]
		if l:projectname == 'new'
			if len(args) < 2
				call s:usage() | return
			else
				let l:projectname = args[1]
				call s:projectnew(l:projectname)
			end
		end
		call s:projectcd(l:projectname)
	end
endf

func! s:projectnew(projectname, ...) " a:1 is templatekind
	call mkdir(s:projectexpand(a:projectname), 'p')
	if a:0 > 0 " and exists in template dictionary :TODO
		system('cp -r '.g:projecttemplate[a:1].'/ '.s:projectexpand(a:projectname))
		call s:info('Created project from '.a:1.' template: '.a:projectname)
	else
		call s:info("Created project: ".s:projectexpand(a:projectname))
	end
endf

func! s:projectcd(projectname)
	exe 'tcd '.s:projectexpand(a:projectname)
	call s:info("pwd: ".getcwd())
endf

func! s:projectexpand(projectname)
	return expand(g:projectdir.a:projectname)
endf

func! s:filter(candidates, arglead)
	return filter(a:candidates, 'match(tolower(v:val), tolower(a:arglead))!=-1')
endf

func! s:warn(msg)
	echohl WarningMsg
	echo a:msg
	echohl Reset
endf

func! s:info(msg)
	echohl HelpType
	echo a:msg
	echohl Reset
endf

