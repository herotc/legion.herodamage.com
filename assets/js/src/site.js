function formatNumber(number) {
  return new Intl.NumberFormat("en-US").format(number);
}

function copyToClipboard(elementId) {
  var copyText = document.getElementById(elementId);
  copyText.select();
  document.execCommand("Copy");
}
