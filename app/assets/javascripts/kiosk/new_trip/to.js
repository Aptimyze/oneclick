jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-to-wizard-step')) return;

  $('.next-step-btn').addClass('stop');
  NewTrip.requirePresenceToContinue($('#trip_proxy_to_place'));
  restore_marker_from_local_storage('stop');

  setupPlacesSearchTypeahead('to', 'stop');
});
