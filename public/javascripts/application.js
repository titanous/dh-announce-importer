var login;
var apiKey;
var domains;
var step = 1;

$(document).ready(function() {
   $('#authForm').validate();
   $('#authForm').submit(authenticate);
});

function authenticate(event) {
    event.preventDefault();
    
    login = $('#login').val();
    apiKey = $('#apiKey').val()
    
    if ($('#authForm').valid()) {
        $('#step1 .error').slideUp();
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

function addDomains() {
    $('#domainList').empty();
    for (key in domains)
        $('#domainList').append('<option value="' + domains[key] + '">' + domains[key] + '</option>');
}

function checkList(event) {
    event.preventDefault();
    
    if ($('#list').val() != '') {
        step = 2;
        $('#step2 .error').slideUp();
        $('#step2 .loading').fadeIn();
        
        $.ajax({
           type: 'POST',
           url: 'check_list',
           dataType: 'text',
           data: ({ list: $('#list').val(), domain: $('#domainList').val() }),
           success: function(data) {
               $('#step2 .loading').fadeOut();
               if (data == 'VALID') {
                   nextStep();
               } else {
                   $('#step2 .error').
                    text('A lookup error occurred. Please check the list name and API permissions.')
                    .hide().slideDown();
               }
           },
           error: function() {
               $('#step2 .loading').fadeOut();
               $('#step2 .error').text('An error ocurred. Please try again later.').hide().slideDown();
           }
        });
    }
}

function addUploader() {
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
}

function nextStep() {
    switch (step) {
        case 1:
        $('#step1 input').attr('disabled', true);
        addDomains();
        $('#step2 input, #step2 select').removeAttr('disabled');
        $('#listForm').submit(checkList);
        break;
        
        case 2:
        $('#step2 input, #step2 select').attr('disabled', true);
        $('#step3 input').removeAttr('disabled');
        addUploader();
        break;
    }
}