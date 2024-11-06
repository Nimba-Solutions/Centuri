#!/bin/bash

# Enable logging
exec 1> >(tee cleanup.log) 2>&1
echo "Starting cleanup at $(date)"

OBJECTS_DIR="../force-app/main/default/objects"

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "Created temp dir: $TEMP_DIR"

# Define objects to explicitly exclude
EXCLUDE_OBJECTS=(
    "AgentWork" "AuditTrailFileExport" "BatchJob" "BatchJobPart" "BatchJobPartFailedRecord"
    "CalcMatrixColumnRange" "CalcProcStepRelationship" "CalculationMatrix" "CalculationMatrixColumn"
    "CalculationMatrixRow" "CalculationMatrixVersion" "CalculationProcedure" "CalculationProcedureStep"
    "CalculationProcedureVariable" "CalculationProcedureVersion" "CaseRelatedIssue" "ChangeRequest"
    "ChangeRequestRelatedIssue" "ChangeRequestRelatedItem" "DTRecordsetReplica" "DecisionTblFileImportData"
    "EmpUserProvisionProcessErr" "EngagementAttendee" "EngagementInteraction" "EngagementInterface"
    "EngagementTopic" "ExpressionSet" "ExpressionSetVersion" "FlowOrchestrationLog" "ForecastingAdjustment"
    "ForecastingCategoryMapping" "ForecastingCustomData" "ForecastingOwnerAdjustment" "ForecastingQuota"
    "ForecastingTypeToCategory" "Incident" "IncidentRelatedItem" "IntegrationProviderAttr"
    "IntegrationProviderDef" "Knowledge__kav" "LinkedArticle" "LocationTrustMeasure" "PendingServiceRouting"
    "Problem" "ProblemIncident" "ProblemRelatedItem" "ProfileSkill" "ProfileSkillEndorsement"
    "ProfileSkillUser" "Quote" "QuoteLineItem" "RecordActnSelItemExtrc" "RecordAlert" "RevenueAsyncOperation"
    "RevenueTransactionErrorLog" "SetupDataSynchronization" "AsyncOperationTracker" "SocialPost" "Survey"
    "SurveyInvitation" "SurveyPage" "SurveyQuestionChoice" "SurveyResponse" "SurveySubject" "SurveyVersion"
    "UserCapabilityPreference" "UserServicePresence" "SurveyQuestionResponse"
)

echo "Copying custom fields without a namespace..."
cd "$OBJECTS_DIR" || exit
find . -path "*/fields/*__c.field-meta.xml" | grep -v "/fields/[A-Z][A-Z0-9]*__" | while read -r file; do
    OBJECT_NAME=$(echo "$file" | cut -d'/' -f2)
    if [[ ! " ${EXCLUDE_OBJECTS[@]} " =~ " ${OBJECT_NAME} " ]]; then
        mkdir -p "$TEMP_DIR/$(dirname "$file")"
        cp "$file" "$TEMP_DIR/$file"
    fi
done

echo "Copying objects without a namespace..."
find . -name "*.object-meta.xml" | grep -v "/[A-Z][A-Z0-9]*__[A-Za-z0-9_]*__c" | while read -r file; do
    OBJECT_NAME=$(echo "$file" | cut -d'/' -f2 | cut -d'.' -f1)
    if [[ ! " ${EXCLUDE_OBJECTS[@]} " =~ " ${OBJECT_NAME} " ]]; then
        mkdir -p "$TEMP_DIR/$(dirname "$file")"
        cp "$file" "$TEMP_DIR/$file"
    fi
done

echo "Copying compactLayouts..."
find . -type d -name "compactLayouts" | while read -r dir; do
    OBJECT_NAME=$(echo "$dir" | cut -d'/' -f2)
    if [[ ! " ${EXCLUDE_OBJECTS[@]} " =~ " ${OBJECT_NAME} " ]]; then
        mkdir -p "$TEMP_DIR/$(dirname "$dir")"
        cp -r "$dir" "$TEMP_DIR/$(dirname "$dir")"
    fi
done

echo "Copying recordTypes..."
find . -type d -name "recordTypes" | while read -r dir; do
    OBJECT_NAME=$(echo "$dir" | cut -d'/' -f2)
    if [[ ! " ${EXCLUDE_OBJECTS[@]} " =~ " ${OBJECT_NAME} " ]]; then
        mkdir -p "$TEMP_DIR/$(dirname "$dir")"
        cp -r "$dir" "$TEMP_DIR/$(dirname "$dir")"
    fi
done

echo "Clearing objects directory..."
rm -rf ./*

echo "Restoring preserved files..."
cp -r "$TEMP_DIR/." .

rm -rf "$TEMP_DIR"
echo "Cleanup completed at $(date)"