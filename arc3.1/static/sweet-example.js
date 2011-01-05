word='hello',wordTemplate=_.template($('#word-template').html());
$('body').append(wordTemplate({word:word}));
