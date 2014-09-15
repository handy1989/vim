set tags+=~/.vim/tags/cpp_src/tags " 设置tags搜索路径
set wildmode=longest,list " Ex命令自动补全采用bash方式"
syntax on
filetype plugin indent on

map <C-n> :NERDTree<CR>

" pathongen
execute pathogen#infect()

" taglist
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Right_Window=1
let Tlist_Sort_Type="name"

" omnicppcomplete
set completeopt=longest,menu
let OmniCpp_NamespaceSearch = 2 " search namespaces in the current buffer and in included files
let OmniCpp_ShowPrototypeInAbbr = 1 " 显示函数参数列表
let OmniCpp_MayCompleteScope = 1 " 输入 :: 后自动补全
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]"]"
