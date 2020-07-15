# project.vim
Quickly jump around projects using vim & fzf.

## Upcoming Features
- [ ] Create new project
- [ ] Clone a project from url

## Installation
### Using [vim-plug](https://github.com/junegunn/vim-plug)
add following to your ~/.vimrc
```vim
Plug 'ihsanturk/project.vim'
```

## Usage
Specifiy your projects directory. Default is `~/projects`
```vim
let g:projectdir = '~/projects'
```
Hit `gpp` to pick from your projects in an fzf prompt to quickly ~`cd`~ `tcd`
into there. (This changes the working directory only for current tab. So you
can have different root directories in different tabs.)

## Disable Mappings
```vim
let g:project_no_mappings = 1
```
