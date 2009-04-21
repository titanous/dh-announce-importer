$(document).ready(function() {
       $('#uploader').fileUpload({
               'uploader': 'uploader.swf',
               'script': 'upload',
               'cancelImg': 'images/close.gif',
               'wmode': 'transparent',
               'buttonImg': ' ',
               'width': 75,
               'displayData': 'percentage',
               'fileDesc': 'CSV files (*.csv);TSV files (*.tsv);Excel spreadsheets (*.xls,*.xlsx);OpenDocument spreadsheets (*.ods)',
               'fileExt': '*.csv;*.tsv;*.txt;*.xls;*.xlsx;*.ods',
               'fileDataName': 'file',
               'auto': true
       });
});