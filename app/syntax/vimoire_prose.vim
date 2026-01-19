" Vim syntax file for vimoire prose
" Language: Vimoire Prose (markdown subset for fiction)
" Maintainer: John
"
" This is a custom syntax for long-form fiction editing.
" Unlike standard markdown, tab-indented lines are paragraphs, not code blocks.
" Delimiters remain visible; only content is styled.

if exists("b:current_syntax")
  finish
endif

" Headers (# through ######)
" Match the hash(es), space, and rest of line
syntax match vimoireH1 /^#\s.*$/
syntax match vimoireH2 /^##\s.*$/
syntax match vimoireH3 /^###\s.*$/
syntax match vimoireH4 /^####\s.*$/
syntax match vimoireH5 /^#####\s.*$/
syntax match vimoireH6 /^######\s.*$/

" Scene break: *** on its own line (possibly with leading whitespace)
syntax match vimoireSceneBreak /^\s*\*\*\*\s*$/

" Block quotes: lines starting with >
syntax match vimoireBlockQuote /^>.*$/

" Fenced divs: ::: name or ::: on its own
syntax match vimoireFencedDiv /^:::.*$/

" Metadata tags: {{chapter.num}}, {{mark}}, {{mark:text}}
syntax match vimoireMetaChapter /{{chapter\.num}}/
syntax match vimoireMetaMark /{{mark}}/
syntax match vimoireMetaMarkText /{{mark:[^}]*}}/

" Inline formatting - order matters: bold+italic before bold before italic
" These match delimiter + content + delimiter, styling the whole thing
"
" Bold+Italic: ***text***
syntax match vimoireBoldItalic /\*\*\*[^*]\+\*\*\*/

" Bold: **text** (but not ***text***)
syntax match vimoireBold /\*\*[^*]\+\*\*/

" Italic: *text* (but not **text**)
" Use negative lookbehind/lookahead via \@<! and \@!
syntax match vimoireItalic /\*[^*]\+\*/

" Italic (underscore variant): _text_
" Requires non-underscore before opening and after closing to avoid mid-word matches
syntax match vimoireItalicUnderscore /\<_[^_]\+_\>/

" Dialogue: "quoted speech"
" Single-line: "text" (open and close on same line)
syntax match vimoireDialogue /"[^"]*"/
" Multi-line: opens with " not closed on line, ends at second " on subsequent line
syntax region vimoireDialogue start=/"[^"]*$/ end=/\(^[^"]*"[^"]*\)\@<="/

" Default highlight links (colorschemes can override)
highlight default link vimoireH1 Title
highlight default link vimoireH2 Title
highlight default link vimoireH3 Title
highlight default link vimoireH4 Title
highlight default link vimoireH5 Title
highlight default link vimoireH6 Title
highlight default link vimoireSceneBreak Special
highlight default link vimoireBlockQuote Comment
highlight default link vimoireFencedDiv Comment
highlight default link vimoireMetaChapter Identifier
highlight default link vimoireMetaMark Identifier
highlight default link vimoireMetaMarkText Identifier
highlight default link vimoireBoldItalic vimoireBoldItalicStyle
highlight default link vimoireBold vimoireBoldStyle
highlight default link vimoireItalic vimoireItalicStyle
highlight default link vimoireItalicUnderscore vimoireItalicStyle
highlight default link vimoireDialogue String

" Default inline styles (attributes only, inherit fg)
highlight default vimoireBoldItalicStyle cterm=bold,italic gui=bold,italic
highlight default vimoireBoldStyle cterm=bold gui=bold
highlight default vimoireItalicStyle cterm=italic gui=italic

let b:current_syntax = "vimoire_prose"
