<?php

function find_photos () {

	$type = 'dlts_photograph';

	$query = "
    SELECT
      n.nid,
			MAX(n.vid) AS vid,
      nr.title,
			cm.field_cropped_master_fid AS fid,
			cm.field_cropped_master_djakota_width AS width,
			cm.field_cropped_master_djakota_height AS height,
			cm.field_cropped_master_djakota_dwtLevels AS dwtLevels,
			cm.field_cropped_master_djakota_compositingLayerCount AS compositingLayerCount,
      handle.field_handle_url AS handle,
			identifier.field_identifier_value AS identifier,
			sequence.field_sequence_number_value AS sequence,
			ispartof.field_photo_set_nid AS isPartOf,
			file.uri,
			file.filename
    FROM {node} n
		LEFT JOIN {node_revision} nr
			ON n.vid = nr.vid
		LEFT JOIN {field_revision_field_cropped_master} cm
      ON n.vid = cm.revision_id
		LEFT JOIN {field_revision_field_handle} handle
	    ON n.vid = handle.revision_id
		LEFT JOIN {field_revision_field_identifier} identifier
		  ON n.vid = identifier.revision_id
		LEFT JOIN {field_revision_field_sequence_number} sequence
		  ON n.vid = sequence.revision_id
		LEFT JOIN {field_revision_field_photo_set} ispartof
		  ON n.vid = ispartof.revision_id
		LEFT JOIN {file_managed} file
		  ON cm.field_cropped_master_fid = file.fid
    WHERE n.type = :type AND nr.status = 1
    GROUP BY n.nid
    ORDER BY n.nid";

	/** Create a database connection to the source (d6) database */
	return Database::getConnection('default', 'drupal6')->query($query, array('type' => $type), array());

}

function find_photo_set ($vid) {
	$query = "SELECT field_identifier_value AS identifier FROM {field_revision_field_identifier} WHERE revision_id = :vid";

	/** Create a database connection to the source (d6) database */
  $result = Database::getConnection('default', 'drupal6')->query($query, array('vid' => $vid), array());

	return $result->fetchObject();

}
