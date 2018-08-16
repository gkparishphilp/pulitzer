#= require ./../plugins/froala/js/froala_editor
#= require ./../plugins/froala/js/plugins/align
#= require ./../plugins/froala/js/plugins/char_counter
#= require ./../plugins/froala/js/plugins/code_view
#= require ./../plugins/froala/js/plugins/code_beautifier
#= require ./../plugins/froala/js/plugins/colors
#= require ./../plugins/froala/js/plugins/font_size
#= require ./../plugins/froala/js/plugins/image
#= require ./../plugins/froala/js/plugins/link
#= require ./../plugins/froala/js/plugins/lists
#= require ./../plugins/froala/js/plugins/paragraph_format
#= require ./../plugins/froala/js/plugins/quote
#= require ./../plugins/froala/js/plugins/table
#= require ./../plugins/froala/js/plugins/url
#= require ./../plugins/froala/js/plugins/video

init_wysiwyg = (container)->

	try

		default_wysiwyg_toolbar_button_presets =
		{
			content: ['bold', 'italic', 'underline', 'fontFamily', 'fontSize', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'quote', '|', 'insertLink', 'insertImage', 'insertVideo', 'insertTable', 'undo', 'redo', 'clearFormatting', '|', 'insertProduct'],
			content_md: ['bold', 'italic', 'underline', 'fontFamily', 'fontSize', '|', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', '|', 'insertLink', 'insertImage', 'insertVideo', 'clearFormatting', '|', 'insertProduct'],
			answer: ['bold', 'italic', '|', 'align', 'formatOL', 'formatUL', '|', 'insertLink', 'insertImage', 'insertVideo', 'clearFormatting', '|', 'insertProduct'],
			answer_md: ['bold', 'italic', '|', 'align', 'formatOL', 'formatUL', '|', 'insertLink', 'insertImage', 'insertVideo', 'clearFormatting', '|', 'insertProduct'],
			list_description: ['bold', 'italic', 'formatOL', 'formatUL', '|', 'insertImage', 'insertLink', 'insertVideo'],
			default: ['bold', 'italic', 'underline', 'strikeThrough', 'color', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'indent', 'outdent', '|', 'insertImage', 'insertLink', 'insertFile', 'insertVideo', 'undo', 'redo'],
			admin_default: ['bold', 'italic', 'underline', 'strikeThrough', 'quote', 'subscript', 'superscript', '|', 'fontSize', 'color', '|', 'paragraphFormat', 'align', '|', 'formatOL', 'formatUL', '|', 'indent', 'outdent', '|', 'insertImage', 'insertLink', 'insertFile', 'insertVideo', '|', 'clearFormatting', '|', 'undo', 'redo', '|', 'html'],
			admin_lite: ['bold', 'italic', 'underline', 'strikeThrough', 'color', '|', 'align', '|', 'insertLink', 'subscript', 'superscript', '|', 'html'],
		}
		$('textarea.wysiwyg', container).each ->
			$this = $(this)

			config = ($this.data('wysiwyg') || {})
			config.toolbar_sticky = config.toolbar_sticky || false
			config.char_counter_count = config.char_counter_count || false

			console.log( 'wysiwyg config', config )

			toolbar_preset = config.toolbar_preset || 'default'

			wysiwyg_toolbar_buttons = config.toolbar_buttons || default_wysiwyg_toolbar_button_presets[toolbar_preset] || default_wysiwyg_toolbar_button_presets['default']
			wysiwyg_toolbar_buttons_md = config.toolbar_buttons_md || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_md"] || wysiwyg_toolbar_buttons
			wysiwyg_toolbar_buttons_sm = config.toolbar_buttons_sm || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_sm"] || wysiwyg_toolbar_buttons_md
			wysiwyg_toolbar_buttons_xs = config.toolbar_buttons_xs || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_xs"] || wysiwyg_toolbar_buttons_sm

			$this.froalaEditor({
				heightMin: $this.data('heightmin') || config.height_min,
				linkInsertButtons: ['linkBack'],
				linkList: false,
				linkMultipleStyles: false,
				toolbarInline: false,
				pastePlain: true,
				charCounterCount: config.char_counter_count,
				placeholderText: $this.attr('placeholder'),
				height: $this.data('height'),
				toolbarSticky: config.toolbar_sticky,
				toolbarStickyOffset: config.toolbar_sticky_offset || $('header>nav').outerHeight(),
				imageUploadURL: (config.asset_manager || '/asset_manager'),
				toolbarButtons: wysiwyg_toolbar_buttons,
				toolbarButtonsMD: wysiwyg_toolbar_buttons_md,
				toolbarButtonsSM: wysiwyg_toolbar_buttons_sm,
				toolbarButtonsXS: wysiwyg_toolbar_buttons_xs,
				zIndex: ($this.data('wysiwyg') || {}).z_index,
			})
			$this.froalaEditor('events.focus') if $this.attr('autofocus')
		$('textarea.wysiwyg-inline', container).each ->
			$this = $(this)

			toolbar_preset = ($this.data('wysiwyg') || {}).toolbar_preset || 'default'

			wysiwyg_toolbar_buttons = ($this.data('wysiwyg') || {}).toolbar_buttons || default_wysiwyg_toolbar_button_presets[toolbar_preset] || default_wysiwyg_toolbar_button_presets['default']
			wysiwyg_toolbar_buttons_md = ($this.data('wysiwyg') || {}).toolbar_buttons_md || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_md"] || wysiwyg_toolbar_buttons
			wysiwyg_toolbar_buttons_sm = ($this.data('wysiwyg') || {}).toolbar_buttons_sm || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_sm"] || wysiwyg_toolbar_buttons_md
			wysiwyg_toolbar_buttons_xs = ($this.data('wysiwyg') || {}).toolbar_buttons_xs || default_wysiwyg_toolbar_button_presets[toolbar_preset+"_xs"] || wysiwyg_toolbar_buttons_sm

			$this.froalaEditor({
				heightMin: $this.data('heightmin') || ($this.data('wysiwyg') || {}).height_min,
				linkInsertButtons: ['linkBack'],
				linkList: false,
				linkMultipleStyles: false,
				toolbarInline: true,
				pastePlain: true,
				charCounterCount: ($this.data('wysiwyg') || {}).char_counter_count || false,
				toolbarContainer: ($this.data('wysiwyg') || {}).toolbar_container || null,
				toolbarVisibleWithoutSelection: ($this.data('wysiwyg') || {}).toolbar_visible_without_selection || false,
				toolbarButtons: wysiwyg_toolbar_buttons,
				toolbarButtonsMD: wysiwyg_toolbar_buttons_md,
				toolbarButtonsSM: wysiwyg_toolbar_buttons_sm,
				toolbarButtonsXS: wysiwyg_toolbar_buttons_xs,
				height: $this.data('height'),
				placeholderText: $this.attr('placeholder'),
			#toolbarSticky: false,
				imageUploadURL: (($this.data('wysiwyg') || {}).assets || '/assets'),
			})
			$this.froalaEditor('events.focus') if $this.attr('autofocus')
	catch e
		window.notice('wysiwyg editor', e)




$(document).on 'ready', (e)->

	container = $(e.target)

	init_wysiwyg( container )
