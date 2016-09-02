class oracle_java {
  include oracle_java::no_revocation_check,
          oracle_java::tools,
	  puavo_pkg

  puavo_pkg::install {
    'oracle-java':
       require => [ File['/opt/java/opinsys-add-cert']
		  , File['/opt/java/opinsys-create-signed-ruleset'] ];
  }
}
