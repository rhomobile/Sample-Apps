function doSync() {
	$.get("/system/syncdb",function(data) {});
	return false;
}
var pageId = 0;
var baseUri = '';

function fastsearch(sender) {
	var productlist = document.getElementById('productlist');
	var items = productlist.childNodes;
	for(var i = 0; i< items.length; i++) {
		var product = items[i]
		if(product.nodeType != 3) {
			var searchname = product.getElementsByTagName('H1')[0].textContent;
			if(searchname.toLowerCase().indexOf(sender.value.toLowerCase(),0) == -1) {
				product.style.display = 'none';
			} else {
				product.style.display = '';
			}
		}
	}
	console.log(sender.value);
}

function getPage(url,execute)
{
	if (window.XMLHttpRequest)
	{
		xmlhttp=new XMLHttpRequest();

		xmlhttp.open("GET",url,false);
		xmlhttp.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
		xmlhttp.setRequestHeader('Transition-Enabled', 'True');
		xmlhttp.send(null);
		if (xmlhttp.responseText != null)
		{
			if(execute) { 
				return eval('(' + xmlhttp.responseText + ')'); 
			} else {
				return xmlhttp.responseText
			}
		} 
	}
	return -1;
}

function goBack(href) {
	var prevPage = document.getElementById('prevPage');
	var currentPage = document.getElementById('currentPage');
	
	if(prevPage) {
		currentPage.style.display = 'none';
		prevPage.style.display = 'block';
		prevPage.id = 'currentPage';
		window.scrollTo(prevPage.getAttribute('scrollx'),prevPage.getAttribute('scrolly'));
		document.body.removeChild(currentPage);
	} else {
		goTo(href);
	}
}

function goTo(href) {
		pageId++;

		var data = getPage(href,false);
		var newPage = document.createElement('div');
		newPage.innerHTML = data;
		newPage = newPage.firstChild;
		currentPage = document.getElementById('currentPage');
		newPage.style.display = 'block';
		newPage.id = 'currentPage';
		newPage.setAttribute('page','page' + pageId);
		newPage.setAttribute('uri',href);
		
		var children = document.body.childNodes;
		for(i = 0; i < children.length; i++) {
			if( children[i].tagName == 'DIV' && children[i].id == 'prevPage') {
				document.body.removeChild(children[i]);
			}
		}
		
		currentPage.id = 'prevPage';
		currentPage.setAttribute('scrollx', window.scrollX);
		currentPage.setAttribute('scrolly', window.scrollY);
		
		currentPage.style.display = 'none';
		document.body.appendChild(newPage);
		window.location = baseUri + '#page' + pageId;
		
		if(currentPage.getAttribute('data-dom-cache') != 'true') {
			document.body.removeChild(currentPage);
		}	
}

function clickHandler(event) {
	var link = event.target;
	//go up the family tree until we find the A tag
	while (link && link.tagName != 'A') {
		link = link.parentNode;
	}
	if (link) {
		var url = link.href;
		
		if(link.getAttribute('data-rel') == 'back') {
			goBack(url);
			return false;
		}
		goTo(url);		

		return false;
	}
	return false;
}

function loadHandler(event) {
	var children = document.body.childNodes;
	
	for(i = 0; i < children.length; i++) {
		if( children[i].tagName == 'DIV') {
			children[i].setAttribute("id","currentPage");
			children[i].setAttribute("page","page" + pageId);

		}
	}
	baseUri = window.location + '';
	window.location = baseUri + '#page' + pageId;
	return true;
}

function hashHandler(event) {
}

window.onload = loadHandler;
window.onhashchange = hashHandler;
document.onclick=clickHandler;