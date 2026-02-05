targetScope = 'subscription'

param userAssignedIdentityId string
param logAnalyticsWorkspaceResourceId string
param logAnalyticsRegion string
@description('default is Qualys, mdeTvm is Defender vulnerability management')
@allowed([
  'default'
  'mdeTvm'
])
param vulnerabilityAssessmentProviderType string = 'mdeTvm'

resource cspmPlan 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'CloudPosture'
  properties: {
    pricingTier: 'Standard'
  }
}

resource serversPlan 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'VirtualMachines'
  dependsOn: [
    cspmPlan
  ]
  properties: {
    pricingTier: 'Standard'
    subPlan: 'P2'
  }
}

resource containersPlan 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'Containers'
  dependsOn: [
    serversPlan
  ]
  properties: {
    pricingTier: 'Standard'
  }
}

resource containersAddonPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2025-03-01' existing = {
  name: 'a8eff44f-8c92-45c3-a3fb-9880802d67a7'
  scope: tenant()
}

resource containersAddonPolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: 'Defender for Containers provisioning Azure Policy Addon for Kub'
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    containersPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'Defender for Containers provisioning Azure Policy Addon for Kubernetes'
    enforcementMode: 'Default'
    policyDefinitionId: containersAddonPolicyDefinition.id
  }
}

resource containersArcExtensionPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2025-03-01' existing = {
  name: '0adc5395-9169-4b9b-8687-af838d69410a'
  scope: tenant()
}

resource containersArcExtensionPolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: 'Defender for Containers provisioning Policy extension for Arc-e'
  #disable-next-line no-loc-expr-outside-params
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    containersPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'Defender for Containers provisioning Policy extension for Arc-enabled Kubernetes'
    enforcementMode: 'Default'
    policyDefinitionId: containersArcExtensionPolicyDefinition.id
  }
}

resource containersProvisioningArcPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2025-03-01' existing = {
  name: '708b60a6-d253-4fe0-9114-4be4c00f012c'
  scope: tenant()
}

resource containersProvisioningArcPolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: 'Defender for Containers provisioning ARC k8s Enabled'
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    containersPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'Defender for Containers provisioning ARC k8s Enabled'
    enforcementMode: 'Default'
    policyDefinitionId: containersProvisioningArcPolicyDefinition.id
  }
}

resource containersSecurityProfilePolicyDefinition 'Microsoft.Authorization/policyDefinitions@2025-03-01' existing = {
  name: '64def556-fbad-4622-930e-72d1d5589bf5'
  scope: tenant()
}

resource containersSecurityProfilePolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: 'Defender for Containers provisioning AKS Security Profile'
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    containersPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'Defender for Containers provisioning AKS Security Profile'
    enforcementMode: 'Default'
    policyDefinitionId: containersSecurityProfilePolicyDefinition.id
  }
}

resource defenderVulnerabilityManagement 'Microsoft.Security/serverVulnerabilityAssessmentsSettings@2023-05-01' = if (vulnerabilityAssessmentProviderType =~ 'mdeTvm') {
  name: 'AzureServersSetting'
  kind: 'AzureServersSetting'
  dependsOn: [
    cspmPlan
    serversPlan
  ]
  properties: {
    selectedProvider: 'MdeTvm'
  }
}

resource vulnerabilityAssessmentQualysPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2025-03-01' existing = {
  name: '13ce0167-8ca6-4048-8e6b-f996402e3c1b'
  scope: tenant()
}

// May be in the future Defender Vulnerability Management will also be configured via policy as the policy supports type
resource vulnerabilityAssessmentQualysPolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = if (vulnerabilityAssessmentProviderType =~ 'default') {
  name: 'ASC auto provisioning of vulnerability assessment agent for mac'
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    cspmPlan
    serversPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'ASC auto provisioning of vulnerability assessment agent for mac'
    enforcementMode: 'Default'
    policyDefinitionId: vulnerabilityAssessmentQualysPolicyDefinition.id
    parameters: {
      vaType: {
        value: vulnerabilityAssessmentProviderType
      }
    }
  }
}

resource autoProvisioning 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  dependsOn: [
    serversPlan
  ]
  properties: {
    autoProvision: 'Off'
  }
}

resource serversMonitorAgentPolicyDefinition 'Microsoft.Authorization/policySetDefinitions@2025-03-01' existing = {
  name: '500ab3a2-f1bd-4a5a-8e47-3e09d9a294c3'
  scope: tenant()
}

resource serversMonitorAgentPolicy 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: 'Custom Defender for Cloud provisioning Azure Monitor agent'
  location: deployment().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  dependsOn: [
    containersPlan
  ]
  properties: {
    description: 'This policy assignment was automatically created by Azure Security Center for agent installation as configured in Security Center auto provisioning.'
    displayName: 'Custom Defender for Cloud provisioning Azure Monitor agent'
    enforcementMode: 'Default'
    policyDefinitionId: serversMonitorAgentPolicyDefinition.id
    parameters: {
      userWorkspaceResourceId: {
        value: logAnalyticsWorkspaceResourceId
      }
      workspaceRegion: {
        value: logAnalyticsRegion
      }
    }
  }
}

#disable-next-line BCP081
resource agentlessScanning 'Microsoft.Security/VmScanners@2022-03-01-preview' = {
  name: 'default'
  dependsOn: [
    cspmPlan
    serversPlan
  ]
  properties: {
    scanningMode: 'Default'
    // You can add exclusion tags to Agentless scanning for machines feature
    exclusionTags: {}
  }
}
