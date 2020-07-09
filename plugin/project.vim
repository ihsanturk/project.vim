" Maintainer: ihsan
" Mail: ihsanl at pm dot me
" Last Change: 2020 Jul 09 16:29:35, @1594301382

let g:projectdir = '~/project/' " FIXME: use get() function
let g:projectexternaldir = '~/project/other/' " FIXME: use get() function

" Add these too: [sh|py|c|cpp|rs|hs]
let g:projecttemplate = {
	\ 'sh': $pwd.'/templates/shell',
	\ 'rs': $pwd.'/templates/rust',
\}

func! s:usage(cmd) " FIXME: add arg for command
	call s:warn(':Project [new] <projectname> [template]')
endf

let s:commands = {
	\ 'cd': { 'funcref': function('s:cd'),
		\ 'argcount': 1,
		\ 'compfunc': 's:list',
	\},
	\ 'new': { 'funcref': function('s:new'),
		\ 'argcount': 1,
		\ 'compfunc': '',
	\},
	\ 'clone': { 'funcref': function('s:clone'),
		\ 'argcount': 1,
		\ 'compfunc': 's:compclone',
	\},
\}

func! s:complete(arg, line, pos)
	let l = split(a:line[:a:pos-1], '\%(\%(\%(^\|[^\\]\)\\\)\@<!\s\)\+', 1)
	let n = len(l) - index(l, 'Project') - 2
	if n > 0
		return call(s:commands[l[1]].compfunc, [a:arg, a:line, a:pos])
	else
		return call('s:compcmd', [a:arg, a:line, a:pos])
	end
endf
func! s:compcmd(arg,line,pos)
	return s:filter(keys(s:commands), a:arg)
endf
func! s:compclone(arg,line,pos)
	" CONTRIBUTE: You can add git providers to this list:
	let comp = [
		\ 'https://github.com/',
		\ 'https://gitlab.com/',
	\]
	return s:filter(comp, a:arg)
endf
func! s:list(arg,line,pos)
	return s:filter(systemlist('ls '.g:projectdir), a:arg)
endf
command! -nargs=* -complete=customlist,s:complete Project
		\ call s:cmd(<f-args>)

func! s:cmd(...) abort
	let args = copy(a:000)
	if len(args) < 1 " no args
		call s:usage() | return " FIXME: add arg for command
	else
		let cmd = args[0]
		if len(args) < s:commands[cmd].argcount + 1 " FIXME
			call s:usage(cmd) | return
		else
			" FIXME: give an arglist as required (argcount) instead of one arg
			call s:commands[cmd].funcref(args[1])
		end
	end
endf

func! s:clone(url)
	let [user, repo] = s:parseurlgit(a:url)
	let targetdir = g:projectexternaldir.'/'.user
	call mkdir(targetdir, 'p')
	call s:info("cloning: ".user.'/'.repo.'...')
	call system('git clone '.a:url.' '.targetdir)
	call s:cd()
endf

func! s:parseurlgit(url)
	let scheme = '^\(http[s]\?:\/\/\)'
	let tilslash = '\([^/]*\)'
	let regex = scheme.tilslash.'\/'.tilslash.'\/'.tilslash
	let result = matchlist(a:url, regex)
	return filter(result, 'v:val != ""')[3:]
endf

func! s:exists(name)
	return isdirectory(s:expand(a:name))
endf

func! s:new(name, ...) " a:1 is templatekind
	if s:exists(a:name)
		call s:warn('project already exists: '. a:name) " FIXME: use my error handler plugin
	else
		call mkdir(s:expand(a:name), 'p')
		if a:0 > 0 " TODO: and exists in template dictionary
			system('cp -r '.g:projecttemplate[a:1].'/ '.s:expand(a:name))
			call s:info('Created project from '.a:1.' template: '.a:name)
		else
			call s:info("Created project: ".s:expand(a:name))
		end
		call s:cd(a:name)
	end
endf

func! s:cd(name)
	exe 'tcd '.s:expand(a:name)
	call s:info("pwd: ".getcwd())
endf

func! s:expand(name)
	return expand(g:projectdir.a:name)
endf

func! s:filter(candidates, arglead)
	return filter(a:candidates, 'match(tolower(v:val), tolower(a:arglead))!=-1')
endf

func! s:warn(msg)
	echohl WarningMsg
	echo '[project.vim]: 'a:msg
	echohl Reset
endf

func! s:info(msg)
	echohl HelpType
	echo '[project.vim]: '.a:msg
	echohl Reset
endf

