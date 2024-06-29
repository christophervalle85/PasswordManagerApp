import AuthenticationServices

class AutoFillViewController: ASCredentialProviderViewController {
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        // Fetch and display credentials based on the serviceIdentifiers.
    }
    
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        // Provide the credential without user interaction.
    }
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        // Prepare the interface for user interaction to select the credential.
    }
}
