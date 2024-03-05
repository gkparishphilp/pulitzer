
$(->

	admin_clipboard = new ClipboardJS('[data-clipboard-target],[data-clipboard-text]');

	$('.select-2-basic').select2();

	$('.select-2-ajax').each ()->
		$taget = $(this)
		$taget.select2
			allowClear: true
			minimumInputLength: 3
			quietMillis: 100
			placeholder: 'Select Option'
			ajax:
				url: $taget.data('url')
				type: 'GET'
				dataType: 'json'
				delay: 100
				data: (params) ->
					{
						q: params.term
						per: 50
						page: params.page
					}
				processResults: (data) ->
					{ results: data }

	$('.toggle').hide()
	$('.toggle-hide').hide()
	$('.toggle-show').click ()->
		$('.toggle').show()
		$('.toggle-hide').show()
		$('.toggle-show').hide()
		return false
	$('.toggle-hide').click ()->
		$('.toggle').hide()
		$('.toggle-hide').hide()
		$('.toggle-show').show()
		return false


	if $('.datepicker').datetimepicker != undefined
		$('.datepicker').datetimepicker
			dateFormat: 'dd MM, yy'
	if $('.datetimepicker').datetimepicker != undefined
		$('.datetimepicker').datetimepicker({
			format: 'YYYY-MM-DD HH:mm:ss Z',
			icons: {
				time: "fa fa-clock-o",
				date: "fa fa-calendar",
				up: "fa fa-chevron-up",
				down: "fa fa-chevron-down",
				next: "fa fa-chevron-right",
				previous: "fa fa-chevron-left",
				today: "fa fa-crosshairs",
				clear: "fa fa-trash",
				close: "fa fa-remove",
			}
		})
);
