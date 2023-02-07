Extension: PopulationDescriptors
Id: patient-population-descriptors
Title: "Population Descriptors"
Description: "Information about the individual's ancestry, ethnicity, race, tribe, etc."
* ^context.type = #element
* ^context.expression =  "Patient"
* value[x] only CodeableConcept 
* valueCodeableConcept from http://purl.org/ga4gh/pedigree-fhir-ig/ValueSet/HumanAncestry (preferred)
* extension 0..0
