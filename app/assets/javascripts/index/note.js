OSM.Note = function (map) {
  var content = $("#sidebar_content"),
      page = {},
      halo, currentNote;

  var noteIcons = {
    "new": L.icon({
      iconUrl: OSM.NEW_NOTE_MARKER,
      iconSize: [25, 40],
      iconAnchor: [12, 40]
    }),
    "open": L.icon({
      iconUrl: OSM.OPEN_NOTE_MARKER,
      iconSize: [25, 40],
      iconAnchor: [12, 40]
    }),
    "closed": L.icon({
      iconUrl: OSM.CLOSED_NOTE_MARKER,
      iconSize: [25, 40],
      iconAnchor: [12, 40]
    })
  };

  page.pushstate = page.popstate = function (path, id) {
    OSM.loadSidebarContent(path, function () {
      initialize(path, id, function () {
        var data = $(".details").data(),
            latLng = L.latLng(data.coordinates.split(","));
        if (!map.getBounds().contains(latLng)) moveToNote();
      });
    });
  };

  page.load = function (path, id) {
    initialize(path, id, moveToNote);
  };

  function initialize(path, id, callback) {
    content.find("input[type=submit]").on("click", function (e) {
      e.preventDefault();
      var data = $(e.target).data();
      var form = e.target.form;

      $(form).find("input[type=submit]").prop("disabled", true);

      $.ajax({
        url: data.url,
        type: data.method,
        oauth: true,
        data: { text: $(form.text).val() },
        success: function () {
          OSM.loadSidebarContent(path, function () {
            initialize(path, id, moveToNote);
          });
        }
      });
    });

    content.find("textarea").on("input", function (e) {
      var form = e.target.form;

      if ($(e.target).val() === "") {
        $(form.close).val(I18n.t("javascripts.notes.show.resolve"));
        $(form.comment).prop("disabled", true);
      } else {
        $(form.close).val(I18n.t("javascripts.notes.show.comment_and_resolve"));
        $(form.comment).prop("disabled", false);
      }
    });

    content.find("textarea").val("").trigger("input");

    var data = $(".details").data(),
        latLng = L.latLng(data.coordinates.split(","));

    if (!halo || !map.hasLayer(halo)) {
      halo = L.circleMarker(latLng, {
        weight: 2.5,
        radius: 20,
        fillOpacity: 0.5,
        color: "#FF6200"
      });
      map.addLayer(halo);
    }

    if (currentNote && map.hasLayer(currentNote)) map.removeLayer(currentNote);

    currentNote = L.marker(latLng, {
      icon: noteIcons[data.status],
      opacity: 1,
      interactive: true
    });

    map.addLayer(currentNote);

    if (callback) callback();
  }

  function moveToNote() {
    var data = $(".details").data(),
        latLng = L.latLng(data.coordinates.split(","));

    if (!window.location.hash || window.location.hash.match(/^#?c[0-9]+$/)) {
      OSM.router.withoutMoveListener(function () {
        map.setView(latLng, 15, { reset: true });
      });
    }
  }

  page.unload = function () {
    if (map.hasLayer(halo)) map.removeLayer(halo);
    if (map.hasLayer(currentNote)) map.removeLayer(currentNote);
  };

  return page;
};
