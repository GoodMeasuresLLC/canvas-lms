$(function() {
  $('a.ic-app-header__logomark').attr('href', 'https://code.goodmeasures.com/log/today');
  $('a.ic-app-header__logomark').on('click', function(event) {
    document.location.href = 'https://code.goodmeasures.com/log/today';
    return false;
  });
});
