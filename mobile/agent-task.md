# One More Rep — Multi-Agent Setup

## Objective
Configure OpenCode to help build the complete One More Rep fitness platform using specialized agents, suitable models, and a reliable development workflow.

## Step 1: Inspect the Project
Read and follow:
- `AGENTS.md`
- `PROJECT_PLAN.md`
- `docs/database/ERD.md`
- Existing Flutter and Laravel code
- Current Git status and OpenCode configuration

Identify the current architecture, existing implementation, missing components, and available tests.

## Step 2: Model Selection
Use only models currently available in my OpenCode model list.

Preferred free hosted models:
- `opencode/big-pickle`
- `opencode/glm-5.3-flash-free`
- `opencode/deepseek-v4.1-flash-free`
- `opencode/mimo-v2.6-flash-free`

Local fallback:
- `ollama/qwen2.5-coder:3b`

Do not select paid models. Verify model availability before assigning them. If a model fails or requires payment, use another available free model or the local fallback.

## Step 3: Specialized Agents
Plan the following agents using OpenCode's supported configuration format:

1. **Build / Coordinator**
   - Coordinates work and integrates changes.
   - Delegates suitable tasks to specialized agents.
   - Prevents conflicting edits.

2. **Flutter Developer**
   - Builds the trainee mobile application.
   - Implements responsive UI, navigation, authentication, workout tracking, and animations.
   - Uses the existing logo, splash image, and Manrope fonts.

3. **Laravel / PostgreSQL Developer**
   - Implements REST APIs, database migrations, models, validation, and business logic.
   - Enforces role-based access and coach/trainee data isolation.

4. **Security Reviewer**
   - Reviews authentication, authorization, tenant isolation, input validation, payment workflows, and secret handling.
   - Reports vulnerabilities and proposes fixes.

5. **Testing / Debugging Agent**
   - Runs available automated tests and static analysis.
   - Diagnoses failures and proposes or applies safe fixes.
   - Never reports tests as passing unless they actually pass.

## Step 4: Project Requirements
- Flutter mobile app.
- Laravel REST API.
- PostgreSQL database.
- Roles: super_admin, coach, trainee.
- Coaches can access only their assigned trainees.
- Trainees can access only their own data.
- A trainee has one primary coach at a time.
- Unlimited trainees per coach.
- Configurable coach subscription plans and durations.
- Manual Vodafone Cash payment verification.
- Backend-validated vouchers and transactional redemption.
- AI provider abstraction with Ollama support.
- Dark premium visual design with royal blue, black, and gray.
- Premium, performant animations and accessible interfaces.
- Arabic RTL support where required.
- Follow existing project documentation and architecture.

## Step 5: Safety Rules
- Start with inspection and a proposed implementation plan.
- Do not modify files until you show the exact proposed configuration changes and ask for approval.
- Do not delete files, expose secrets, change Git history, push to Git, or perform destructive database operations.
- Do not overwrite existing user assets.
- Avoid conflicting simultaneous edits to the same files.
- Preserve existing project work.
- Prefer small, verifiable changes and run relevant tests after implementation.

## Expected First Response
Report:
1. Current project status.
2. Proposed OpenCode configuration files and agent definitions.
3. The exact model assigned to each agent.
4. Any free-model availability or usage-limit uncertainty.
5. The changes you intend to make.

Wait for my approval before editing files.