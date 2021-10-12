### Scope

Family health history is an important aspect in both genomic research and patient care. The Global Alliance for Genomics and Health is working on a pedigree standard that will allow sharing family history data in a way that is accurate, easy to analyse and transferable between systems. The group has created a [conceptual model](https://github.com/GA4GH-Pedigree-Standard/pedigree/blob/master/model.md) and a [minimal data set document](https://docs.google.com/document/d/1UAtSLBEQ_7ePRLvDPRpoFpiXnl6VQEJXL2eQByEmfGY/) that have been used as the basis for this FHIR implementation guide.

### Understanding FHIR (Prerequisite)

This implementation guide uses terminology, notations and design principles that are specific to FHIR. Before reading this implementation guide, its important to be familiar with some of the basic principles of FHIR as well as general guidance on how to read FHIR specifications. Readers who are unfamiliar with FHIR are encouraged to read (or at least skim) the following prior to reading the rest of this implementation guide.

- [FHIR overview](http://hl7.org/fhir/overview.html)
- [Developer's Introduction](http://hl7.org/fhir/overview-dev.html)
- [Clinical Introduction](http://hl7.org/fhir/overview-clinical.html)
- [FHIR data types](http://hl7.org/fhir/datatypes.html)
- [Using codes](http://hl7.org/fhir/terminologies.html)
- [References between resources](http://hl7.org/fhir/references.html)
- [How to read resource and profile definitions](http://hl7.org/fhir/formats.html)
- [Base resource](http://hl7.org/fhir/resource.html)

This implementation guide builds on FHIR v4.0.1: R4.

### Mappings

This section describes how the elements in the conceptual model were mapped to FHIR.

The main classes in the conceptual model are shown in the following diagram:

<img src="https://user-images.githubusercontent.com/4251264/105409205-1c53b200-5bfe-11eb-9d77-ed5630138eaf.png" alt="Class model" style="float:none"/>

The FHIR resources that were used to implement the conceptual model are shown in the following diagram:

<img src="model.png" alt="FHIR model" style="float:none"/>

The following sections describe how each element was mapped to FHIR.

#### Individual

The individual class is mapped to the [Patient](https://www.hl7.org/fhir/patient.html) resource through the [PedigreeIndividual profile](StructureDefinition-PedigreeIndividual.html).

##### Properties

| Field       | Type           | Status          | Definition                                                                                                                                                                                                          | FHIR Mapping               | Comments                                                                                                                                     |
| ----------- | -------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| id          | ID             | required        | logical id                                                                                                                                                                                                          | id                         | All FHIR resources have a logical identifier.                                                                                                |
| name        | string         | optional        | Name of the individual                                                                                                                                                                                              | name                       |                                                                                                                                              |
| identifiers | list of string | optional        | External identifiers for the individual                                                                                                                                                                             | identifier                 |                                                                                                                                              |
| sex         | Concept        | optional        | Sex for Clinical Use, values: `male`, `female`, `other`, `unknown`; See: https://confluence.hl7.org/display/VOC/Gender+Harmony+Context+Definitions and https://www.hl7.org/fhir/valueset-administrative-gender.html | gender                     | This is the administrative gender of the patient. Biological sex can be supported using an Observation.                                      |
| gender      | Concept        | optional        | Presumed or reported gender identity, values: `male`, `female`, `non-binary`, `non-disclosed`, `trans`, ...; See: https://confluence.hl7.org/display/VOC/Gender+Harmony+Context+Definitions                         | Gender Identity extension  | This is an official HL7 extension used to record gender identity.                                                                            |
| lifeStatus  | Concept        | recommended     | The presumed/accepted life status of the individual as of the pedigree collection date; one of: `alive`, `deceased`, `unborn`                                                                                       | Unborn extension (boolean) | This is the only extension introduced in the implementation guide. FHIR supports recording if a patient is deceased but not if it is unborn. |
| affected    | boolean        | not recommended | Whether or not the individual is affected by the condition being investigated in this pedigree; included for PED backwards compatibility                                                                            | AffectedStatus profile     | This is supported through an observation.                                                                                                    |

#### Relationship

The relationship class is mapped to the [FamilyMemberHistory](https://www.hl7.org/fhir/familymemberhistory.html) resource. This class, along with the official HL7 [patient-record](https://www.hl7.org/fhir/extension-familymemberhistory-patient-record.html) extension, can be used as a relationship in a graph model. The main source of confusion when using this class for this purpose is that it includes redundant information about the individuals, which is needed when a proper graph model is not implemented. Therefore, in the [PedigreeRelationship profile](StructureDefinition-PedigreeRelationship.html), the elements that capture redundant information are forbidden, thus making it clear that the intention is for this resource to be used just as a relationship.

##### Properties

| Field      | Type    | Status   | Definition                                                                                                                                                                                                                                                                                         | FHIR Mapping       | Comments                                                                                                                      |
| ---------- | ------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| id         | ID      | required | Logical id                                                                                                                                                                                                                                                                                         | id                 | All FHIR resources have a logical identifier.                                                                                 |
| individual | ID      | required | Identifier of the subject Individual; equivalent to the Biolink "Subject" and similar to the FHIR "Player"                                                                                                                                                                                         | patient            |                                                                                                                               |
| relative   | ID      | required | Identifier of the relative Individual; equivalent to the Biolink "Object" and similar to the FHIR "Scoping Individual"                                                                                                                                                                                                   | relative extension | Uses the official HL7 [patient-record](https://www.hl7.org/fhir/extension-familymemberhistory-patient-record.html) extension. |
| relation   | Concept | required | The relationship between `individual` and `relative`; if the relationship is directed, it is the relationship that the individual has to the relative (e.g., individual is the mother, relative is the child, then relation is isBiologicalParentOf); terms should come from the relationship terminology, below | relationship       | A new FHIR code system was created and the binding was set to required.                                                       |

##### Relationship Terminology

The relationship terminology is specified [here](https://docs.google.com/spreadsheets/d/1V5i-pbOPgg9_F52lYkQpqYbk3u4MIAc9TNw8aglvLL4/edit?usp=sharing). A FHIR code system that implements this terminology has been developed as part of the implementation guide and can be browsed [here](https://ontoserver.csiro.au/shrimp/?system=http%3A%2F%2Fga4gh-cp.github.io%2Fpedigree-fhir-ig%2FCodeSystem%2FPedigreeRelationships&concept=REL%3A001&version=0.1.0&valueset=http%3A%2F%2Fga4gh-cp.github.io%2Fpedigree-fhir-ig%2FCodeSystem%2FPedigreeRelationships%3Fvs).

#### Pedigree

There is no resource in FHIR that represents an entire pedigree. Therefore, this class is mapped to the [Composition](https://www.hl7.org/fhir/composition.html) resource, which provides a generic mechanism to package a set of related resources, through the [Pedigree profile](StructureDefinition-Pedigree.html).

##### Properties

| Field           | Type    | Status   | Definition                                                                                                                                | FHIR Mapping            | Comments                                                                                                                           |
| --------------- | ------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| proband         | ID      | optional | Id of Individual that is the index case for the family                                                                                    | proband section         | The composition has a section where a reference to the proband can be established.                                                 |
| date     | Date    | optional | The date the pedigree was collected or last updated, as ISO full or partial date, i.e. YYYY, YYYY-MM, or YYYY-MM-DD                                       | date                    |                                                                                                                                    |
| reason | Concept | optional | The health condition being investigated in the family; if any Individual has the `affected` property defined, it refers to this condition | reasonCollected section | The composition has a section where a reference to the condition that is the reason the pedigree was collected can be established. |

### Examples

Currently, there are two examples in the implementation guide.

#### The Simpsons Family

This is a simple example that shows how the profiles and other resources can be used to build a simple family history graph. The following figure shows what the model looks like:

<img src="simpsons_example.png" alt="Simpsons example" style="float:none"/>

The following instances are used to implement this example:

- [Bart](Patient-Bart.html)
- [Marge](Patient-Marge.html)
- [Homer](Patient-Homer.html)
- [Abe](Patient-Abe.html)
- [Bart-Marge Relationship](FamilyMemberHistory-BartMargeRelationship.html)
- [Bart-Homer Relationship](FamilyMemberHistory-BartHomerRelationship.html)
- [Marge-Homer Relationship](FamilyMemberHistory-BartHomerRelationship.html)
- [Homer-Abe Relationship](FamilyMemberHistory-HomerAbeRelationship.html)
- [Bart's Condition](Condition-BartsCondition.html)
- [Dr Nick](Practitioner-DrNick.html)
- [Simpsons Pedigree](Composition-SimpsonsPedigree.html)

#### A Geric Trio

An example trio from the testing suite of the [GenoVic system](https://doi.org/10.1016/j.pathol.2018.12.345).

The following instances are used to implement this example:

- [Mother](Patient-Mother.html)
- [Affected Status Mother](Observation-AffectedStatusMother.html)
- [Father](Patient-Father.html)
- [Affected Status Father](Observation-AffectedStatusFather.html)
- [Proband](Patient-Proband.html)
- [Affected Status Proband](Observation-AffectedStatusProband.html)
- [Proband-Father Relationship](FamilyMemberHistory-ProbandFatherRelationship.html)
- [Proband-Mother Relationship](FamilyMemberHistory-ProbandMotherRelationship.html)
- [Melbourne Genomics](Organization-MelbourneGenomics.html)
- [Trio Pedigree](Composition-TrioPedigree.html)

#### Connectathon

##### Pedigree 1

<img src="pedigree-1.png" alt="pedigree 1" style="float:none"/>
