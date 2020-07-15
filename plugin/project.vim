"            ╭────────────────────project.vim───────────────────╮
"            Maintainer:  ihsan, ihsanl[at]pm[dot]me            │
"            Description: Manage projects                       │
"            Last Change: 2020 Jul 15 17:44:15 +03, @1594824263 │
"            License:     MIT                                   │
"            ╰──────────────────────────────────────────────────╯

" load check
if exists("g:loaded_project_vim")
	finish
endif
let g:loaded_project_vim = 1

" setup
let g:orrer#mainprg = 'project'
let g:orrer#dict = {
	\ 'E0': {
		\ 'message': '`fd` or `find` not found',
		\ 'suggestions': [
			\ 'install fd or find',
		\ ],
	\},
	\ 'E1': {
		\ 'message': 'fzf.vim not found',
		\ 'suggestions': [
			\ "install: https://github.com/junegunn/fzf.vim",
		\ ],
	\},
\}

" vars
let g:projectdir = get(g:, 'projectdir', '~/project/')
let g:project_no_mappings  = get(g:, 'project_no_mappings', 0)

" functions
" TODO: Show only project name not full path in fzf.
fu! project#select()
	if executable('fd') | let FIND = 'fd . -d 3 --type d '.g:projectdir |
	elseif executable('find') | let FIND='find '.g:projectdir.' -type d -d 3' |
	else | try | cal orrer#fatal('E0') | endtry
	end
	if exists("*fzf#run")
		cal fzf#run(fzf#wrap({'source':FIND,'sink':function('s:fzf_select_handler')}))
	else
		try | cal orrer#fatal('E1') | endtry
	end
endf
fu! s:fzf_select_handler(fzfoutput)
	exe 'tcd '.a:fzfoutput
	" cal s:info('pwd: '.getcwd()) " FIXME: cannot notify user where user is.
endf
fu! s:warn(msg)
	echoh WarningMsg | ec '[project]: 'a:msg | echoh Reset 
endf
fu! s:info(msg)
	echoh HelpType | ec '[project]: '.a:msg | echoh Reset
endf

" maps
nm <Plug>ProjectSelect :<C-U>cal project#select()<cr>
if !exists("g:project_no_mappings") || ! g:project_no_mappings
	nm gpp <Plug>ProjectSelect
end
