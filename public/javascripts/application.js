var login;
var apiKey;
var domains;
var step = 1;

$(document).ready(function() {
   $('#uploader').fileUpload({
       uploader: 'uploader.swf',
       script: 'upload',
       cancelImg: 'images/close.gif',
       wmode: 'transparent',
       buttonImg: ' ',
       width: 75,
       displayData: 'percentage',
       fileDesc: 'CSV files (*.csv);TSV files (*.tsv);Excel spreadsheets (*.xls,*.xlsx);OpenDocument spreadsheets (*.ods)',
       fileExt: '*.csv;*.tsv;*.xls;*.xlsx;*.ods',
       fileDataName: 'file',
       auto: true
   });
   
   $('#authForm').validate();
   
   $('#authForm').submit(authenticate);
});

function authenticate(event) {
    event.preventDefault();
    
    login = $('#login').val();
    apiKey = $('#apiKey').val()
    
    if ($('#authForm').valid()) {
        $('#step1 div.error').slideUp();
        $('#step1 .loading').fadeIn();
        
        $.ajax({
           type: 'POST',
           url: 'authenticate',
           dataType: 'json',
           data: ({ login: login, api_key: apiKey }),
           success: function(data) {
               $('#step1 .loading').fadeOut();
               domains = data;
               nextStep();
           },
           error: function(request, status) {
               $('#step1 .loading').fadeOut();
               var errorText
               
               if (status == 'parsererror') { // got LOGINERROR message
                   errorText = 'A login error ocurred. Please check your login/API key.';
               } else {
                   errorText = 'An error ocurred. Please try again later.';
               }
               
               $('#step1 div.error').text(errorText).hide().slideDown();
           }
        });
    }
}

function nextStep() {
    
}