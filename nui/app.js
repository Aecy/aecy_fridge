function openMenu(items) {
	$('.container').css({display: 'flex'});
	$('.container').fadeIn();

	items.forEach((item) => {
		$('.lapicole-shop_items').append(`
			<div class="item-slot" data-prop="${item.prop}" data-name="${item.name}" data-image="${item.image}" data-price="${item.price}">
				<div class="item-slot-img">
					<img src="${item.image}" alt="${item.name}">
				</div>
				<div class="item-slot-label">
					<p>${item.name}</p>
				</div>
			</div>
		`);
	});
}

function closeMenu() {
	$('.container').css({display: 'none'});
	$('.container').fadeOut();
	$.post('https://vsrp-drinktogether/close', JSON.stringify({}));
}

$(document).keyup(function (event) {
	if (event.which == 27) {
		$.post('https://vsrp-drinktogether/close', JSON.stringify({}));
	}
});

$(document).on('click', '.item-slot', function (event) {
	let itemName = $(this).data('name');
	let itemImage = $(this).data('image');
	let itemPrice = $(this).data('price');
	let itemProp = $(this).data('prop');

	$('.lapicole-preview').css({display: 'flex'});
	$('.lapicole-preview').fadeIn();

	$('.lapicole-preview').html(`
		<img src="${itemImage}" />
		<div>
			Nom de l'objet: ${itemName} <br/>
			Quantité: ${itemPrice}<br/><br/>

			<div class="lapicole-preview-buy" data-prop="${itemProp}" data-item="${itemName}">
				Prendre
			</div>
		</div>
	`);
});

$(document).on('click', '.lapicole-preview-buy', function (event) {
	$('.lapicole-preview').css({display: 'none'});
	$('.lapicole-preview').fadeOut();

	$.post('https://vsrp-drinktogether/buy', JSON.stringify({
		name: $(this).data('item'),
		prop: $(this).data('prop')
	}));
});

window.addEventListener('message', function (event) {
	switch (event.data.action) {
		case 'open':
			openMenu(event.data.items);
			break;
		case 'close':
			closeMenu()
			break;
	}
});