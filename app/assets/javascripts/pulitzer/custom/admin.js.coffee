
$(->

	admin_clipboard = new ClipboardJS('[data-clipboard-target],[data-clipboard-text]');

	$('.select-2-basic').select2();

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
