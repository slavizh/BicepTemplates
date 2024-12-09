

keyVaultProperties: {
  keyVaultUri: keyVault.properties.vaultUri
  keyName: keyVaultKey.name
  keyVersion: !empty(keyVaultKeyVersion)
    ? keyVaultKeyVersionRes.name
    : last(split(keyVaultKey.properties.keyUriWithVersion, '/'))
}
