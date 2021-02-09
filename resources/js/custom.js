/*https://www.sitepoint.com/url-parameters-jquery/*/
$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}

/*http://stackoverflow.com/questions/5448545/how-to-retrieve-get-parameters-from-javascript*/
function findGetParameter(parameterName) {
    var result = null,
        tmp = [];
    var items = location.search.substr(1).split("&");
    for (var index = 0; index < items.length; index++) {
        tmp = items[index].split("=");
        if (tmp[0] === parameterName) result = decodeURIComponent(tmp[1]);
    }
    return result;
}

/* script for loading the content of the modal */
$(document).ready(function(){
   var trigger = $('a[data-key],a[data-keys]');
   $(trigger).click(function(){
   var dataType = $( this ).attr('data-type');
   var dataKey = $( this ).attr('data-key');
   var dataKeys = $( this ).attr('data-keys');
   if(dataKeys != undefined){
      let keys = dataKeys.split(' ');
      let promises = [];
      for (let i = 0; i < keys.length; i++){
          let dataTypeInKey = '';
          let key = '';
            if (keys[i].startsWith('work')){ dataTypeInKey = 'listwork.xml'; key = keys[i].substring(5,keys[i].length); }
            else if (keys[i].startsWith('org')){ dataTypeInKey = 'listorg.xml'; key = keys[i].substring(4,keys[i].length); }
            else if (keys[i].startsWith('person')){ dataTypeInKey = 'listperson.xml'; key = keys[i].substring(7,keys[i].length); }
            else if (keys[i].startsWith('place')){ dataTypeInKey = 'listplace.xml'; key = keys[i].substring(6,keys[i].length); }
          let url = "showNoTemplate.html?directory=indices&document=" + dataTypeInKey + "&entiyID=" + key;
          
		  $('#myModal').remove();
		  
		  promises[i] = $.get(url, function(data){
			  let myModal = document.getElementById('myModal');
			  if (myModal == undefined){
				$('#loadModal').append(data);
			  }
			  else{
				  let parser = new DOMParser();
				  let contentToInsert = parser.parseFromString(data,'text/html');
				  let subTree = contentToInsert.getElementsByClassName('modal-content')[0];
				  let subTreeToInsert = $(subTree).clone();
				  $('.modal-dialog').append(subTreeToInsert);
			  }
			});
      }
      Promise.all(promises).then(function(){
        $('#linksModal').remove();
        $('#myModal').modal('show');
        $('#linksModal').modal('show');
        $('#linksModal').focus();
              
        let handlesForModalLinks = $('#linksModal div div a');
        $(handlesForModalLinks).each(function(){$(this).click(function(){
            let dataType = $( this ).attr('data-type');
            let dataKey = $( this ).attr('data-key');
            let baseUrl = "showNoTemplate.html?directory=indices&document=";
            let url = baseUrl + dataType + "&entiyID=" + dataKey;
            $('#loadModal').load(url, function(){
                $('.modal-backdrop').remove();
                $('#linksModal').remove();
                $('#myModal').modal('show');
            });
        });
        });
		// handle pmb relations for more than one modal
			let linksIntoPMB = $('#myModal div div div h3 small a');
			let pmbKeys = new Array();
			for (let i = 0; i < linksIntoPMB.length; i++){
				if (linksIntoPMB[i] !== undefined){
					let reference = $(linksIntoPMB[i]).attr('href');
					let pmbKey = 0;
					if (reference !== undefined){
						let position = reference.lastIndexOf('pmb');
						pmbKey = reference.substring(position + 3,reference.length);
						pmbKeys.push(pmbKey);
					}
				}
			}
			for (let j = 0; j < pmbKeys.length; j++){
				// make request to pmb and process them
				let url = 'https://pmb.acdh.oeaw.ac.at/apis/api2/entity/' + pmbKeys[j] + '/?format=json';
				let promise = $.get(url,function(data){
					if (data.entity_type === 'Institution' || data.entity_type === 'Place' || data.entity_type === 'Person' || data.entity_type === 'Event' || data.entity_type === 'Work'){
					// persons relations
					for (let i = 0; i < data.relations.persons.length; i++){
						let idOfRelation = data.relations.persons[i].target.id;
						let labelOfRelation = data.relations.persons[i].relation_type.label;
						let targetOfRelation = data.relations.persons[i].target.name;
						let firstname = data.relations.persons[i].target.first_name;
						let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/person/' + idOfRelation +'/detail';
						if (firstname) {
							if (targetOfRelation) {
								var name = firstname + ' ' + targetOfRelation;
							} else {
								var name = firstname;
							};
						} else 
							{ var name = targetOfRelation; };
						if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

						} else {
							var str = labelOfRelation;
						}
						$('#myModal div div .modal-body-pmb').eq(j).append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + name + '</a></div>');
					}
					// works relations
					for (let i = 0; i < data.relations.works.length; i++){
						let idOfRelation = data.relations.works[i].target.id;
						let labelOfRelation = data.relations.works[i].relation_type.label;
						let targetOfRelation = data.relations.works[i].target.name;
						let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/' + idOfRelation +'/detail';
						if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n + 3);

						} else {
							var str = labelOfRelation;
						}
						$('#myModal div div .modal-body-pmb').eq(j).append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
					}
					// events relations
					for (let i = 0; i < data.relations.events.length; i++){
						let idOfRelation = data.relations.events[i].target.id;
						let labelOfRelation = data.relations.events[i].relation_type.label;
						let targetOfRelation = data.relations.events[i].target.name;
						let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/event/' + idOfRelation +'/detail';
						if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n + 3);

						} else {
							var str = labelOfRelation;
						}
						$('#myModal div div .modal-body-pmb').eq(j).append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
					}
					// institutions relations
					for (let i = 0; i < data.relations.institutions.length; i++){
						let idOfRelation = data.relations.institutions[i].target.id;
						let labelOfRelation = data.relations.institutions[i].relation_type.label;
						let targetOfRelation = data.relations.institutions[i].target.name;
						let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/institution/' + idOfRelation +'/detail';
						if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n + 3);
						} else {
							var str = labelOfRelation;
						}
						$('#myModal div div .modal-body-pmb').eq(j).append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
					}
					// places relations
					for (let i = 0; i < data.relations.places.length; i++){
						let idOfRelation = data.relations.places[i].target.id;
						let labelOfRelation = data.relations.places[i].relation_type.label;
						let targetOfRelation = data.relations.places[i].target.name;
						let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/' + idOfRelation +'/detail';
						if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

						} else {
							var str = labelOfRelation;
						}
						$('#myModal div div .modal-body-pmb').eq(j).append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
					}
				}
			});
			// make request to pmb and process them - end
			}
		// handle pmb relations for more than one modal - end
      });
   }
   else{
       var xsl = dataType.replace(".xml", "");
       var baseUrl = "showNoTemplate.html?directory=indices&document="
       var url = baseUrl + dataType + "&entiyID=" + dataKey;
       $('#loadModal').load(url, function(){
		   
		// new code start
	  let mentionedLink = $('#myModal div div div h3 small a');
	  if (mentionedLink !== undefined){
		let reference = $(mentionedLink).attr('href');
		let pmbKey = 0;
		if (reference !== undefined){
			// console.log(reference);
			let position = reference.lastIndexOf('pmb');
			pmbKey = reference.substring(position + 3,reference.length);
		}
		else{
			mentionedLink = $('#myModal div div div h4 a'); // this case should not be necessary because the delivered html for the modal was corrected
			if (mentionedLink !== undefined){
				let reference = $(mentionedLink).attr('href');
				if (reference !== undefined){
					let position = reference.lastIndexOf('pmb');
					pmbKey = reference.substring(position + 3,reference.length);
				}
			}
		}
		// make request to pmb and process them
		let url = 'https://pmb.acdh.oeaw.ac.at/apis/api2/entity/' + pmbKey + '/?format=json';
		let promise = $.get(url,function(data){
			if (data.entity_type === 'Institution' || data.entity_type === 'Place' || data.entity_type === 'Person' || data.entity_type === 'Event' || data.entity_type === 'Work'){
				// persons relations
				for (let i = 0; i < data.relations.persons.length; i++){
					let idOfRelation = data.relations.persons[i].target.id;
					let labelOfRelation = data.relations.persons[i].relation_type.label;
					let targetOfRelation = data.relations.persons[i].target.name;
					let firstname = data.relations.persons[i].target.first_name;
					let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/person/' + idOfRelation +'/detail';
					if (firstname) {
					    if (targetOfRelation) {
					        var name = firstname + ' ' + targetOfRelation;
					    } else {
					        var name = firstname;
					    };
					} else 
					{ var name = targetOfRelation;};
					if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

					} else {
					    var str = labelOfRelation;
					}
					$('.modal-body-pmb').append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + name + '</a></div>');
				}
				// works relations
				for (let i = 0; i < data.relations.works.length; i++){
					let idOfRelation = data.relations.works[i].target.id;
					let labelOfRelation = data.relations.works[i].relation_type.label;
					let targetOfRelation = data.relations.works[i].target.name;
					let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/' + idOfRelation +'/detail';
					if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

					} else {
					    var str = labelOfRelation;
					}
					$('.modal-body-pmb').append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// events relations
				for (let i = 0; i < data.relations.events.length; i++){
					let idOfRelation = data.relations.events[i].target.id;
					let labelOfRelation = data.relations.events[i].relation_type.label;
					let targetOfRelation = data.relations.events[i].target.name;
					let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/event/' + idOfRelation +'/detail';
					if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

					} else {
					    var str = labelOfRelation;
					}
					$('.modal-body-pmb').append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// institutions relations
				for (let i = 0; i < data.relations.institutions.length; i++){
					let idOfRelation = data.relations.institutions[i].target.id;
					let labelOfRelation = data.relations.institutions[i].relation_type.label;
					let targetOfRelation = data.relations.institutions[i].target.name;
					let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/institution/' + idOfRelation +'/detail';
					if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

					} else {
					    var str = labelOfRelation;
					}
					$('.modal-body-pmb').append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
				// places relations
				for (let i = 0; i < data.relations.places.length; i++){
					let idOfRelation = data.relations.places[i].target.id;
					let labelOfRelation = data.relations.places[i].relation_type.label;
					let targetOfRelation = data.relations.places[i].target.name;
					let linkhref = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/' + idOfRelation +'/detail';
					if (labelOfRelation.includes('>>')) {
					    	var n = labelOfRelation.lastIndexOf('>>');
					        var str = labelOfRelation.substring(n+3);

					} else {
					    var str = labelOfRelation;
					}
					$('.modal-body-pmb').append('<div class="pmbAbfrageText">' + str + ' <a href="' + linkhref + '">' + targetOfRelation + '</a></div>');
				}
			}
		});
		// make request to pmb and process them - end
	  }
	  // new code end   
		   
       $('#myModal').modal('show');
       });
   }   
   });
});