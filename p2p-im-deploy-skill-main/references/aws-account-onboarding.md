# AWS Account Onboarding

Read this file before any new AWS/Lightsail install, AWS readiness check,
account creation guidance, instance selection, or paid-resource confirmation.

Authoritative public references:

- AWS account creation guide: https://aws.amazon.com/resources/create-account/
- AWS account overview and first-time setup: https://docs.aws.amazon.com/accounts/latest/reference/accounts-welcome.html
- AWS root user guidance: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html

## Account Readiness Gate

Ask the user these questions before release preflight:

1. Do you already have an AWS account that is active and able to create
   Lightsail resources?
2. Can you sign in to the AWS Console yourself?
3. Which AWS region do you want for the P2P IM node?
4. Do you want the Agent to check a local AWS CLI profile, or will you finish
   account setup first?

If the user does not have an active AWS account, stop deployment and guide the
user through account creation. Do not start release preflight, do not create
credentials, and do not create paid resources.

## Official AWS Signup Flow

Direct the user to the official AWS account creation page. The stable steps are:

1. Enter root user email and account name, then verify email.
2. Add contact information.
3. Add a payment method.
4. Verify phone number.
5. Choose a support plan.
6. Wait for account activation; AWS says activation is usually quick but can
   take up to 24 hours.

After account creation, ask the user to sign in themselves and protect the root
user. AWS guidance is to use the root user only for tasks that require root
privileges and to use MFA for root protection.

## What The Agent May Ask

The Agent may ask for:

- confirmation that signup and activation are complete
- selected region
- whether the user wants the release scripts to use an existing local AWS CLI
  profile
- local path to a credentials CSV only if the release manifest declares an AWS
  key importer flow
- explicit paid-resource confirmation after showing release-declared pricing
  and billing notes

## What The Agent Must Not Ask

Never ask the user to provide:

- payment card number or billing verification details
- root password
- email verification code
- phone verification code
- MFA code
- root access key
- AWS secret access key pasted into chat
- screenshot containing secrets

If AWS requires one of these values, tell the user to enter it directly on the
official AWS page or local AWS tooling. The Agent must not handle it.

## Instance Selection

Use the release manifest, not this reference, as the source of current plans and
prices. Current release packages expose this through
`agent_deployment.lightsail_plan_recommendations`.

Ask only product-language sizing questions:

- expected friends or contacts
- expected groups
- expected channels
- retained history and media/file volume
- expected Agent/MCP activity

Present only the release-declared choices. If the user is unsure, choose the
manifest-declared default plan. Show the current monthly price, billing note,
region, and deletion requirement before asking for paid confirmation.

## Stop Conditions

Stop and report the exact blocker when:

- account activation is not complete
- the user cannot sign in to AWS
- no supported region or Lightsail bundle is declared by the release manifest
- AWS CLI/preflight fails and no release-declared recovery action exists
- the user has not confirmed paid resource creation
- the user is being asked for a secret the Agent must not collect

Do not route around these stops with manual console operations unless the
release manifest declares that operation and the user explicitly confirms it.
