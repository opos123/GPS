import QtQuick 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15
import QtQml.XmlListModel 6.6  // Sesuaikan versi sesuai dengan instalasi Qt Anda

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Map Application"

    // Properti untuk menyimpan respons dari geocoding
    property var geocodeResponse

    // Fungsi untuk melakukan geocoding alamat
    function geocodeAddress(address) {
        var url = "https://nominatim.openstreetmap.org/search?q=" + encodeURIComponent(address) + "&format=json&addressdetails=1";
        console.log("Geocode URL: " + url);
        var request = new XMLHttpRequest();
        request.open("GET", url, true);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    geocodeResponse = JSON.parse(request.responseText);
                    console.log("Geocode Response: " + request.responseText);
                    if (geocodeResponse.length > 0) {
                        var latitude = parseFloat(geocodeResponse[0].lat);
                        var longitude = parseFloat(geocodeResponse[0].lon);
                        var altitude = geocodeResponse[0].altitude ? parseFloat(geocodeResponse[0].altitude) : 0;
                        console.log("Geocoded Latitude: " + latitude + ", Longitude: " + longitude + ", Altitude: " + altitude);
                        map.center = QtPositioning.coordinate(latitude, longitude, altitude);
                        map.zoomLevel = 14;
                        altitudePanSlider.value = altitude;
                    } else {
                        console.log("Location not found");
                        searchResultLabel.text = "Location not found";
                    }
                } else {
                    console.log("Geocoding request failed: " + request.status);
                    searchResultLabel.text = "Geocoding request failed";
                }
            }
        }
        request.send();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Column {
            spacing: 10
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            // TextField untuk memasukkan alamat pencarian
            TextField {
                id: searchField
                placeholderText: "Penelusuran Lokasi"
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                onAccepted: {
                    geocodeAddress(searchField.text)
                }
            }

            // Tombol untuk melakukan pencarian geocode
            Button {
                text: "Search"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    geocodeAddress(searchField.text)
                }
            }

            // Label untuk menampilkan hasil pencarian
            Label {
                id: searchResultLabel
                text: ""
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 40

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                // Slider untuk mengatur zoom level peta
                Slider {
                    id: zoomSlider
                    from: 1
                    to: 20
                    stepSize: 1
                    orientation: Qt.Horizontal
                    value: map.zoomLevel
                    height: 40
                    width: 200
                    onValueChanged: {
                        map.zoomLevel = value
                    }
                }

                Label {
                    text: "Zoom Level: " + zoomSlider.value
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                // Slider untuk mengatur longitude peta
                Slider {
                    id: horizontalPanSlider
                    from: 95
                    to: 141
                    value: map.center.longitude
                    orientation: Qt.Horizontal
                    width: 200
                    height: 40
                    onValueChanged: {
                        map.center = QtPositioning.coordinate(map.center.latitude, value, map.center.altitude)
                    }
                }

                Label {
                    text: "Longitude: " + horizontalPanSlider.value
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                // Slider untuk mengatur latitude peta
                Slider {
                    id: verticalPanSlider
                    from: -10
                    to: 6
                    value: map.center.latitude
                    orientation: Qt.Horizontal
                    height: 40
                    width: 200
                    onValueChanged: {
                        map.center = QtPositioning.coordinate(value, map.center.longitude, map.center.altitude)
                    }
                }

                Label {
                    text: "Latitude: " + verticalPanSlider.value
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                // Slider untuk mengatur Altitude peta
                Slider {
                    id: altitudePanSlider
                    from: 0
                    to: 10000
                    value: 0
                    orientation: Qt.Horizontal
                    height: 40
                    width: 200
                    onValueChanged: {
                        map.center = QtPositioning.coordinate(map.center.latitude, map.center.longitude, altitudePanSlider.value)
                    }
                }

                Label {
                    text: "Altitude: " + altitudePanSlider.value.toFixed(6)
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Label {
                    text: "Latitude: " + verticalPanSlider.value.toFixed(6)
                }

                Label {
                    text: "Longitude: " + horizontalPanSlider.value.toFixed(6)
                }

                Label {
                    text: "Altitude: " + altitudePanSlider.value.toFixed(6)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Komponen Map untuk menampilkan peta
            Map {
                id: map
                anchors.fill: parent
                plugin: Plugin {
                    name: "osm"
                }
                center: QtPositioning.coordinate(-6.737246, 108.550659)
                zoomLevel: 14
                property var startCentroid

                // Handler untuk pinch zoom pada peta
                PinchHandler {
                    id: pinch
                    target: null
                    onActiveChanged: if (active) {
                        map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
                    }
                    onScaleChanged: (delta) => {
                        map.zoomLevel += Math.log2(delta)
                        map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                    }
                    onRotationChanged: (delta) => {
                        map.bearing -= delta
                        map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                    }
                    grabPermissions: PointerHandler.TakeOverForbidden
                }

                // Handler untuk pengaturan zoom menggunakan roda mouse
                WheelHandler {
                    id: wheel
                    acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                     ? PointerDevice.Mouse | PointerDevice.TouchPad
                                     : PointerDevice.Mouse
                    rotationScale: 1/120
                    property: "zoomLevel"
                }

                // Handler untuk menggeser peta dengan drag
                DragHandler {
                    id: drag
                    target: null
                    onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
                }

                // MouseArea untuk menangani double click pada peta
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        map.center = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                        map.zoomLevel += 1;
                    }
                }

                // Shortcut untuk zoom in menggunakan keyboard
                Shortcut {
                    enabled: map.zoomLevel < map.maximumZoomLevel
                    sequence: StandardKey.ZoomIn
                    onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
                }

                // Shortcut untuk zoom out menggunakan keyboard
                Shortcut {
                    enabled: map.zoomLevel > map.minimumZoomLevel
                    sequence: StandardKey.ZoomOut
                    onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
                }

                MapQuickItem {
                    id: gpsMarker
                    coordinate: QtPositioning.coordinate(-6.731131,108.553176)
                    anchorPoint: Qt.point(10, 10)
                    sourceItem: Image {
                        source: "qrc:/placeholder.png" // Pastikan path gambar benar
                        width: 20
                        height: 20
                    }
                }
            }

            // Komponen PositionSource untuk mendapatkan posisi pengguna
            PositionSource {
                id: positionSource
                active: true
                onPositionChanged: {
                    map.center = positionSource.position.coordinate
                }
            }
        }
    }
}
