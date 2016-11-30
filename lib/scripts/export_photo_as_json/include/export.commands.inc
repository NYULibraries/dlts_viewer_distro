<?php

function export_photos_nodes_as_json() {
  $pathinfo = pathinfo(__DIR__);
  $destination_directory = $pathinfo['dirname'] . '/data';
  foreach (find_photos() as $photo) {
    $set = find_photo_set($photo->vid);
    $record = array();
    $record['title'] = $photo->title;
    $record['identifier'] = $photo->identifier;
    $record['handle'] = $photo->handle;
    $record['sequence'] = array();
    $record['sequence'][] = $photo->sequence;
    $record['isPartOf'] = array();
    $record['isPartOf'][] = $set->identifier;
    $record['cm'] = array();
    $record['cm']['width'] = $photo->width;
    $record['cm']['height'] = $photo->height;
    $record['cm']['dwtLevels'] = $photo->dwtLevels;
    $record['cm']['compositingLayerCount'] = $photo->compositingLayerCount;
    $record['cm']['uri'] = str_replace('public://', 'fileserver://',$photo->uri);
    $filename = $set->identifier . '.' . $photo->identifier . '.json';
    $destination = $destination_directory . '/' . $filename;
    file_put_contents($destination, json_encode($record));
  }
}
