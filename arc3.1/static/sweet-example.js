(xs=[],render=(function(){return jQuery("#xs").empty(),_.each(xs,(function(x){return jQuery("#xs").append((("<"+"div"+">")+x+("</"+"div"+">")));}));}),jQuery((("<"+"input"+">")+("</"+"input"+">"))).change((function(){return xs.unshift(jQuery(this).val()),jQuery(this).val(""),render();})).appendTo("body"),jQuery((("<"+"div"+" "+("id"+"="+"\"xs\""+" ")+">")+("</"+"div"+">"))).appendTo("body"));
