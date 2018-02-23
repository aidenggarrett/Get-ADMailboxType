<#
    .Synopsis
    Retrieves a the mailbox type of an AD account
    .Description
    The Get-ADMailboxType will query the specified domain controller and retrieve the mailbox type. It will then interpret the value in to a name.
    .Notes
    NAME: Get-ADUserSummary
    AUTHOR: Aiden Garrett
    Revision: v0.1
    Date: 2018/02/23
    To Do:
    Erorr Handling
    Only query the global catalogue
    
    #Requires -Version 1
    #Requires -Modules ActiveDirectory
#>
Function Get-ADMailboxType
    {
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        
        # $Identity
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [string]$Identity,

        # Domain Controller
        [Parameter(Mandatory=$false,
                    ValueFromPipeline=$true,
                    Position=1)]
        [string]$Server

    )

        # Populate $Server if it's equal to null
        #if ( $Server -eq $null ) { $Server = (Get-ADDomainController -Discover -Service "GlobalCatalog").Name }

        # Retrieve AD information

        Write-Verbose "Retrieving Basic AD Details"

        $DisplayName = (Get-ADUser $Identity -Server $Server -Properties DisplayName).DisplayName
        $CanonicalName = (Get-ADUser $Identity -Server $Server -Properties CanonicalName).CanonicalName
        $EmailAddress = (Get-ADUser $Identity -Server $Server -Properties EmailAddress).EmailAddress

        # Retrieve Mailbox Type

        $tmpDBType = (Get-ADUser $Identity -Properties msExchRecipientTypeDetails -Server $Server).msExchRecipientTypeDetails
        if ($tmpDBType -eq '2147483648' ) { $MailboxType = 'Exchange Online' } else { 
           if ($tmpDBType -eq '1') { $MailboxType = 'User Mailbox' }
                else { $Database = 'N/A' }
                }

        # Retrieve Mailbox Database

        # Write-Verbose "Retrieving Mailbox Database"

        if ($tmpDBType -eq '1') { $Database = (Get-AdUser $Identity -Server $Server -Properties homeMDB).homeMDB.split(",=")[1] }
                else { $Database = 'N/A' }

        # Write information to console

        Write-Verbose "AD Account Summary"

        Write-Host "Display Name:" $DisplayName
        Write-Host "OU:" $CanonicalName
        Write-Host "Email Address:" $EmailAddress
        Write-Host "Mailbox Type:" $MailboxType
        Write-Host "Database:" $Database
}