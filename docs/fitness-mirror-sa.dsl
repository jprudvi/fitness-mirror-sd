workspace "Smart Fitness Mirror Platform" "A software platform for an IoT-based Smart Fitness Mirror with edge AI coaching, cloud analytics, and Stripe integration" {
    model {
        // DDD component modeling rules:
        // 1. Components are tagged by layer: Interface, Application, DomainAggregate, DomainService, Infrastructure.
        // 2. ACL/adaptation components use the suffix "ACL"; orchestration components use "Orchestrator" or "Service".
        // 3. Later bounded-context refactors should route inbound requests through Interface/Application components before the domain layer.
        visitor = person "Visitor" "Anonymous user who browses public website content and may sign up or apply as a coach." "Visitor"
        fitnessUser = person "Fitness User" "Uses the Smart Fitness Mirror to train and track fitness progress."
        fitnessCoach = person "Fitness Coach" "Provides exercise and technique data for ML model training."
        techSupport = person "Technical Support Staff Member" "Monitors system performance and handles maintenance."
        rndTeam = person "R&D Team Member" "Analyzes trends and improves the platform."
        platformOwner = person "Platform Owner" "Approves high-level decisions and reviews business strategic analytics."
        crmStaff = person "Platform CRM Staff Member" "Manages subscriptions, equipment renting, and customer support."
        stripe = softwareSystem "Stripe" "Processes monthly/annual subscription and equipment renting payments." "External"
        mirrorHardware = softwareSystem "Smart Mirror Hardware" "Physical device with camera, sensors, and display." "External, Hardware"
        smartFitnessPlatform = softwareSystem "Smart Fitness Mirror Platform" "IoT-based fitness platform with edge AI coaching, cloud analytics, and CRM." {
            modelRegistry = container "Model Registry" "Stores and versions trained ML models ready for deployment." "MLflow" "Database"
            messageBroker = container "Message Broker" "Asynchronous message broker for event-driven communication." "RabbitMQ" "MessageBroker"
            embeddedApp = container "Smart Mirror Embedded Application" "Embedded software controlling the Smart Mirror hardware." "C++" "IoT" {
                embeddedControlInterface = component "Embedded Control Interface" "Interface: Handles session control commands and sensor stream coordination requests." "C++" "Interface"
                sessionControlService = component "Session Control Service" "Application Service: Coordinates device control, stream capture, and local buffering workflows." "C++" "Application"
                deviceController = component "Device Controller Aggregate" "Aggregate Root: Manages device state, hardware commands, and session control invariants." "C++" "DomainAggregate"
                sessionManager = component "Session Manager" "Domain Service: Manages training session data streams and local buffering rules." "C++" "DomainService"
                hal = component "Hardware Abstraction Layer (HAL)" "Decouples device controller from physical sensor drivers." "C++" "Infrastructure"
                hardwareACL = component "Hardware ACL" "Anti-Corruption Layer: Protects domain logic from hardware-specific implementation details." "C++" "Infrastructure,ACL"
                localBufferAdapter = component "Local Buffer Adapter" "Infrastructure Service: Buffers session video recordings to the local file system." "C++" "Infrastructure"
            }
            edgeApp = container "Fitness Local Station Edge Application" "Edge software for AI coaching and analytics." "Python" "Edge" {
                coachingSessionAPI = component "Coaching Session API" "Interface: Handles real-time session data ingestion and coaching recommendation responses." "Python" "Interface"
                edgeAccessAPI = component "Edge Access API" "Interface: Handles local analytics, recommendation, and training plan queries." "Python" "Interface"
                coachingSessionService = component "Coaching Session Service" "Application Service: Coordinates real-time coaching workflows and session progression." "Python" "Application"
                edgeInsightService = component "Edge Insight Service" "Application Service: Resolves local analytics, recommendations, and training plan views." "Python" "Application"
                coachingSession = component "Coaching Session Aggregate" "Aggregate Root: Manages the real-time AI coaching state and feedback." "Python" "DomainAggregate"
                motionProcessor = component "Motion Processor" "Domain Service: Processes raw sensor and camera data for ML consumption." "Python" "DomainService"
                mlModelInterface = component "ML Model ACL" "Anti-Corruption Layer: Decouples coaching logic from specific ML engine implementations." "Python" "Infrastructure,ACL"
                localMLModel = component "Local ML Model" "Pre-trained ML model refined with user data." "LiteRT" "Infrastructure"
                mlFeedbackLoop = component "ML Feedback Loop" "Domain Service: Collects user performance data to improve model accuracy locally." "Python" "DomainService"
                edgeAnalytics = component "Edge Analytics" "Domain Service: Generates local fitness insights and progression data." "Python" "DomainService"
                dataSyncManager = component "Data Sync Orchestrator" "Handles the Outbox pattern for reliable cloud uploads and model updates." "Python" "Application"
                trainingPlans = component "Training Plans" "Manages available training plans." "Python" "DomainService"
                edgeRepository = component "Edge Repository" "Infrastructure Service: Persists and loads session highlights, recommendations, plans, and Outbox entries." "Python" "Infrastructure"
                localFileAdapter = component "Local File Adapter" "Infrastructure Service: Stores local recordings and deployed ML models on the device file system." "Python" "Infrastructure"
            }
            edgeDB = container "Edge Database" "Stores structured data like recommendations and plans on the edge (SQLite)." "SQLite" "Database"
            localFileSystem = container "Fitness Local Station File System" "Stores media like video recordings and deployed ML models." "File System" "FileSystem"
            mobileApp = container "Mobile Application" "Allows users to review analytics, recommendations, training plans, share achievements, and join group sessions." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "MobileApp" {
                mobileGatewayProxy = component "Mobile Gateway Proxy" "Orchestrates requests to Edge and Cloud services, acting as a client-side API Gateway." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Application,Facade"
                trainingSessionUI = component "Training Session UI" "The core interface for starting, managing, and following AI-guided workouts." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
                analyticsUI = component "Analytics UI" "Displays user performance and trends." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
                recommendationsUI = component "Recommendations UI" "Displays AI-generated recommendations." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
                trainingPlansUI = component "Training Plans UI" "Displays available training plans." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
                socialSharing = component "Social Sharing" "Enables sharing achievements." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
                groupSession = component "Group Session" "Manages remote group training sessions." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android), WebRTC" "Interface,UI"
                userProfileUI = component "User Profile UI" "Allows users to manage their profile and identity settings." "Swift/SwiftUI (iOS), Kotlin/Jetpack Compose (Android)" "Interface,UI"
            }
            mobileDB = container "Mobile Database" "Stores a subset of user data for performance on the mobile device (SQLite)." "SQLite" "Database"
            website = container "Fitness Mirror Platform Website" "Serves the fitness platform's web application content." "TypeScript, Angular" "StaticContent" {
                staticContent = component "Static Content" "Serves Angular PWA files." "TypeScript, Angular" "Interface,StaticContent"
            }
            webClientApp = container "Fitness Mirror Platform Web Client App" "Client-side fitness application executed in the user's browser." "TypeScript, Angular" "Browser" {
                userAnalyticsUI = component "User Analytics UI" "Allows Fitness Users to review their performance and achievements." "TypeScript, Angular" "Interface,UI"
                coachExerciseUI = component "Coach Exercise UI" "Allows Fitness Coaches to submit and manage exercise technique data." "TypeScript, Angular" "Interface,UI"
                subscriptionMgmtUI = component "Subscription Management UI" "Allows CRM Staff to manage user subscriptions and billing." "TypeScript, Angular" "Interface,UI"
                strategicAnalyticsUI = component "Strategic Analytics UI" "Provides Platform Owners with business-level insights and reports." "TypeScript, Angular" "Interface,UI"
                systemMonitoringUI = component "System Monitoring UI" "Allows Technical Support to monitor platform health and performance." "TypeScript, Angular" "Interface,UI"
                trendAnalysisUI = component "Trend Analysis UI" "Allows R&D Team to analyze fitness progression and technique trends." "TypeScript, Angular" "Interface,UI"
                modelTrainingUI = component "Model Training UI" "Allows R&D Team to trigger retraining jobs and evaluate experiments." "TypeScript, Angular" "Interface,UI"
            }
            apiGateway = container "API Gateway" "Routes requests to microservices." "AWS API Gateway" "Gateway"
            iamService = container "IAM Service" "Commodity Bounded Context: Manages user identity and access." "Java, Spring Boot" "Microservice,CommodityContext" {
                registrationAPI = component "Registration API" "Interface: Handles sign-up and coach application requests." "Java, Spring Boot" "Interface"
                authenticationAPI = component "Authentication API" "Interface: Handles login, token refresh, and logout requests." "Java, Spring Boot" "Interface"
                profileAPI = component "Profile API" "Interface: Handles profile and identity management requests." "Java, Spring Boot" "Interface"
                authorizationAPI = component "Authorization API" "Interface: Handles authorization and access validation requests." "Java, Spring Boot" "Interface"
                registrationService = component "Registration Service" "Application Service: Orchestrates user registration and onboarding flows." "Java, Spring Boot" "Application"
                authenticationService = component "Authentication Service" "Application Service: Authenticates users and issues IAM tokens." "Java, Spring Boot" "Application"
                profileService = component "Profile Service" "Application Service: Manages profile updates and identity preferences." "Java, Spring Boot" "Application"
                authorizationService = component "Authorization Service" "Application Service: Evaluates roles and permissions for protected operations." "Java, Spring Boot" "Application"
                userAccount = component "User Account Aggregate" "Aggregate Root: Manages user profile data, credentials, and account state." "Java, Spring Boot" "DomainAggregate"
                iamRepository = component "IAM Repository" "Infrastructure Service: Persists and loads user accounts, roles, and credentials." "Java, Spring Boot" "Infrastructure"
                tokenProviderACL = component "Token Provider ACL" "Anti-Corruption Layer: Encapsulates token issuance and external identity token formats." "Java, Spring Boot" "Infrastructure,ACL"
                userRegisteredPublisher = component "User Registered Publisher" "Infrastructure Service: Publishes user registration events to downstream consumers." "Java, Spring Boot" "Infrastructure"
                subscriptionClientACL = component "Subscription Client ACL" "Anti-Corruption Layer: Links newly registered users with the Subscription Service." "Java, Spring Boot" "Infrastructure,ACL"
            }
            iamDB = container "IAM Database" "Stores user credentials, roles, and tokens." "PostgreSQL" "Database"
            performanceService = container "Performance Service" "Core Bounded Context: Manages real-time fitness performance data." "Java, Spring Boot" "Microservice,CoreContext" {
                trainingSessionAPI = component "Training Session API" "Interface: Handles training session lifecycle and performance write requests." "Java, Spring Boot" "Interface"
                performanceQueryAPI = component "Performance Query API" "Interface: Handles performance history and achievement query requests." "Java, Spring Boot" "Interface"
                trainingSessionService = component "Training Session Service" "Application Service: Orchestrates training session commands and completion workflows." "Java, Spring Boot" "Application"
                performanceQueryService = component "Performance Query Service" "Application Service: Retrieves performance history and achievement summaries." "Java, Spring Boot" "Application"
                achievementService = component "Achievement Service" "Application Service: Coordinates achievement evaluation for completed training sessions." "Java, Spring Boot" "Application"
                trainingSession = component "Training Session Aggregate" "Aggregate Root: Manages the lifecycle and invariants of a training session." "Java, Spring Boot" "DomainAggregate"
                achievementCalculator = component "Achievement Calculator" "Domain Service: Calculates user achievements based on performance." "Java, Spring Boot" "DomainService"
                performanceRepository = component "Performance Repository" "Infrastructure Service: Persists and loads training sessions, metrics, and achievements." "Java, Spring Boot" "Infrastructure"
                workoutCompletedPublisher = component "Workout Completed Publisher" "Infrastructure Service: Publishes workout completion events for downstream consumers." "Java, Spring Boot" "Infrastructure"
            }
            performanceDB = container "Performance Database" "Stores system performance data (InfluxDB)." "InfluxDB" "Database"
            apiGateway -> trainingSessionAPI "Routes session lifecycle and performance write requests"
            apiGateway -> performanceQueryAPI "Routes performance history and achievement queries"
            trendsService = container "Trends Service" "Core Bounded Context: Manages exercise and technique trends." "Java, Spring Boot" "Microservice,CoreContext" {
                trendQueryAPI = component "Trend Query API" "Interface: Handles trend history and aggregate trend query requests." "Java, Spring Boot" "Interface"
                trendEventConsumer = component "Trend Event Consumer" "Interface: Consumes workout completion events that trigger trend recalculation." "Java, Spring Boot" "Interface"
                trendQueryService = component "Trend Query Service" "Application Service: Retrieves historical trend data and aggregate trend views." "Java, Spring Boot" "Application"
                trendAnalysisService = component "Trend Analysis Service" "Application Service: Coordinates trend recalculation workflows from incoming workout events." "Java, Spring Boot" "Application"
                fitnessTrend = component "Fitness Trend Aggregate" "Aggregate Root: Manages user fitness progression and technique trends." "Java, Spring Boot" "DomainAggregate"
                trendAnalyzer = component "Trend Analyzer" "Domain Service: Analyzes exercise data to identify trends and improvements." "Java, Spring Boot" "DomainService"
                trendsRepository = component "Trends Repository" "Infrastructure Service: Persists and loads trend aggregates, history, and derived metrics." "Java, Spring Boot" "Infrastructure"
                trendAnalyzedPublisher = component "Trend Analyzed Publisher" "Infrastructure Service: Publishes trend analysis outcomes for downstream consumers." "Java, Spring Boot" "Infrastructure"
            }
            trendsDB = container "Trends Database" "Stores exercise and technique trends (InfluxDB)." "InfluxDB" "Database"
            apiGateway -> trendQueryAPI "Routes trend queries and historical trend requests"
            messageBroker -> trendEventConsumer "Delivers workout completion events for trend recalculation"
            subscriptionService = container "Subscription Service" "Supporting Bounded Context: Manages user subscriptions and billing." "Java, Spring Boot" "Microservice,SupportingContext" {
                subscriptionAPI = component "Subscription API" "Interface: Handles subscription management and provisioning requests." "Java, Spring Boot" "Interface"
                billingAPI = component "Billing API" "Interface: Handles payment processing and billing lifecycle requests." "Java, Spring Boot" "Interface"
                subscriptionManagementService = component "Subscription Management Service" "Application Service: Orchestrates subscription lifecycle changes and provisioning flows." "Java, Spring Boot" "Application"
                paymentService = component "Payment Service" "Application Service: Orchestrates payment flows and billing interactions with the payment gateway." "Java, Spring Boot" "Application"
                subscription = component "Subscription Aggregate" "Aggregate Root: Manages user subscription state and billing cycles." "Java, Spring Boot" "DomainAggregate"
                subscriptionRepository = component "Subscription Repository" "Infrastructure Service: Persists and loads subscriptions, billing cycles, and renting state." "Java, Spring Boot" "Infrastructure"
                subscriptionEventPublisher = component "Subscription Event Publisher" "Infrastructure Service: Publishes subscription-related domain events." "Java, Spring Boot" "Infrastructure"
                stripeACL = component "Stripe ACL" "Anti-Corruption Layer: Protects the subscription domain from Stripe-specific API models." "Java, Spring Boot" "Infrastructure,ACL"
            }
            subscriptionDB = container "Subscription Database" "Stores subscription and renting data (Oracle)." "Oracle" "Database"
            analyticsService = container "Analytics Service" "Generic Bounded Context: Generates strategic business insights." "Java, Spring Boot" "Microservice,GenericContext" {
                analyticsQueryAPI = component "Analytics Query API" "Interface: Handles historical analytics and user-facing analytics query requests." "Java, Spring Boot" "Interface"
                strategicInsightsAPI = component "Strategic Insights API" "Interface: Handles strategic insight and business reporting requests." "Java, Spring Boot" "Interface"
                analyticsEventConsumer = component "Analytics Event Consumer" "Interface: Consumes domain events for analytics aggregation." "Java, Spring Boot" "Interface"
                historicalAnalyticsService = component "Historical Analytics Service" "Application Service: Retrieves historical analytics and achievement summaries." "Java, Spring Boot" "Application"
                strategicInsightService = component "Strategic Insight Service" "Application Service: Produces strategic insight views from aggregated reports." "Java, Spring Boot" "Application"
                eventIngestionService = component "Event Ingestion Service" "Application Service: Coordinates event ingestion and report aggregation workflows." "Java, Spring Boot" "Application"
                strategicInsightGenerator = component "Strategic Insight Generator" "Domain Service: Analyzes aggregated data to produce business strategic insights." "Java, Spring Boot" "DomainService"
                dataAggregator = component "Data Aggregator" "Application Service: Aggregates events from various contexts for reporting." "Java, Spring Boot" "Application"
                analyticsReport = component "Analytics Report Aggregate" "Aggregate Root: Manages the lifecycle and state of generated reports." "Java, Spring Boot" "DomainAggregate"
                analyticsRepository = component "Analytics Repository" "Infrastructure Service: Persists and loads analytics reports, history, and strategic summaries." "Java, Spring Boot" "Infrastructure"
            }
            analyticsDB = container "Analytics Database" "Stores analytics data (PostgreSQL with TimescaleDB)." "PostgreSQL (TimescaleDB)" "Database"
            mediaService = container "Media Service" "Supporting Bounded Context: Manages video uploads, transcoding, and streaming." "Java, Spring Boot" "Microservice,SupportingContext" {
                uploadAPI = component "Upload API" "Interface: Handles video upload initiation and completion requests." "Java, Spring Boot" "Interface"
                mediaAccessAPI = component "Media Access API" "Interface: Handles media metadata, access policy, and playback access requests." "Java, Spring Boot" "Interface"
                uploadOrchestrator = component "Upload Orchestrator" "Application Service: Coordinates upload validation, metadata registration, and raw media archival." "Java, Spring Boot" "Application"
                mediaAccessService = component "Media Access Service" "Application Service: Resolves media metadata, URLs, and access policies for clients." "Java, Spring Boot" "Application"
                transcodingWorkflowService = component "Transcoding Workflow Service" "Application Service: Coordinates transcoding completion and processed media publication workflows." "Java, Spring Boot" "Application"
                mediaMetadataManager = component "Media Metadata Manager" "Aggregate Root: Manages video metadata, URLs, and access policies." "Java, Spring Boot" "DomainAggregate"
                transcoderACL = component "Transcoder ACL" "ACL: Decouples media logic from specific video transcoding services." "Java, Spring Boot" "Infrastructure,ACL"
                mediaStorageAdapter = component "Media Storage Adapter" "Infrastructure Service: Stores processed media files and updates storage-level access policies." "Java, Spring Boot" "Infrastructure"
                mediaDataLakeAdapter = component "Data Lake Adapter" "Infrastructure Service: Archives raw media recordings for AI and auditing workloads." "Java, Spring Boot" "Infrastructure"
                cdnInvalidationAdapter = component "CDN Invalidation Adapter" "Infrastructure Service: Updates CDN cache and distribution policies for media playback." "Java, Spring Boot" "Infrastructure"
                mediaEventPublisher = component "Media Event Publisher" "Infrastructure Service: Publishes media processing and availability events." "Java, Spring Boot" "Infrastructure"
            }
            mediaStorage = container "Media Storage" "Stores processed video files for streaming and user review." "Amazon S3" "Database"
            cdn = container "Content Delivery Network" "Delivers media content with low latency to users." "CloudFront" "StaticContent"
            dataLake = container "Data Lake" "Stores large-scale raw sensor data, video recordings, and technique data for AI R&D." "Amazon S3" "Database"
            modelTrainingService = container "ML Model Training Service" "Core Bounded Context: Trains and refines ML models using aggregated data." "Python, PyTorch" "Microservice,CoreContext" {
                trainingJobAPI = component "Training Job API" "Interface: Handles retraining job requests and experiment execution commands." "Python" "Interface"
                modelEvaluationAPI = component "Model Evaluation API" "Interface: Handles model evaluation and experiment result queries." "Python" "Interface"
                modelTrainingOrchestrator = component "Model Training Orchestrator" "Application Service: Coordinates retraining jobs, preprocessing, training, and model registration." "Python" "Application"
                modelEvaluationService = component "Model Evaluation Service" "Application Service: Retrieves model versions and experiment outcomes for evaluation." "Python" "Application"
                trainingJob = component "Training Job Aggregate" "Aggregate Root: Manages the lifecycle, parameters, and outcomes of a model training job." "Python" "DomainAggregate"
                dataPreprocessor = component "Data Preprocessor" "Domain Service: Cleans and formats raw data for model training." "Python" "DomainService"
                modelTrainer = component "Model Trainer" "Domain Service: Executes model training and validation jobs." "Python" "DomainService"
                trainingDataLakeAdapter = component "Training Data Lake Adapter" "Infrastructure Service: Loads training datasets and experiment inputs from the data lake." "Python" "Infrastructure"
                modelRegistryAdapter = component "Model Registry Adapter" "Infrastructure Service: Registers trained models and loads version metadata from the model registry." "Python" "Infrastructure"
            }
            visitor -> website "Requests the SPA route and receives the app shell for public content"
            visitor -> staticContent "Requests the SPA route and receives the app shell for public content"
            visitor -> webClientApp "Uses the Angular SPA after the app shell loads"
            visitor -> mobileApp "Signs up or applies to become a user or coach via IAM"
            fitnessUser -> mobileApp "Uses for training and reviews data"
            fitnessUser -> webClientApp "Reviews analytics and manages account via domain-specific UI"
            fitnessCoach -> webClientApp "Provides exercise/technique data via Coach Exercise UI"
            techSupport -> webClientApp "Monitors system performance via System Monitoring UI"
            rndTeam -> webClientApp "Analyzes trends and manages model training for R&D via Trend Analysis and Model Training UIs"
            platformOwner -> webClientApp "Reviews strategic analytics via Strategic Analytics UI"
            crmStaff -> webClientApp "Manages subscriptions and support via Subscription Management UI"
            fitnessUser -> mobileApp "Authenticates and manages profile"
            fitnessCoach -> webClientApp "Authenticates and manages profile"
            techSupport -> webClientApp "Authenticates and manages profile"
            rndTeam -> webClientApp "Authenticates and manages profile"
            platformOwner -> webClientApp "Authenticates and manages profile"
            crmStaff -> webClientApp "Authenticates and manages profile"
            embeddedControlInterface -> coachingSessionAPI "Sends session data and receives coaching recommendations"
            embeddedControlInterface -> sessionControlService "Invokes device control and session buffering workflows"
            sessionControlService -> deviceController "Coordinates device state transitions and hardware commands"
            sessionControlService -> sessionManager "Coordinates sensor streaming and local session buffering"
            deviceController -> hal "Sends hardware commands"
            sessionManager -> hal "Streams sensor data for recording"
            hal -> hardwareACL "Interacts with physical drivers"
            hardwareACL -> mirrorHardware "Communicates with physical devices"
            sessionManager -> localBufferAdapter "Requests buffering of session video recordings"
            localBufferAdapter -> localFileSystem "Stores buffered session recordings"
            mobileGatewayProxy -> edgeAccessAPI "Fetches analytics, recommendations, plans, and shares achievements"
            coachingSessionAPI -> coachingSessionService "Invokes real-time coaching workflows"
            edgeAccessAPI -> edgeInsightService "Invokes local analytics, recommendation, and training plan queries"
            coachingSessionService -> coachingSession "Creates and updates coaching session state"
            coachingSessionService -> motionProcessor "Requests movement analysis"
            coachingSessionService -> mlFeedbackLoop "Coordinates local model feedback updates"
            coachingSessionService -> trainingPlans "Loads plans to guide recommendations"
            coachingSessionService -> edgeRepository "Stores session highlights and loads plan data"
            motionProcessor -> mlModelInterface "Sends processed data for inference"
            mlModelInterface -> localMLModel "Executes inference and performs model refinement"
            mlFeedbackLoop -> mlModelInterface "Requests model refinement based on local data"
            edgeInsightService -> edgeAnalytics "Generates local insights and progression data"
            edgeInsightService -> edgeRepository "Loads analytics, recommendations, and training plan data"
            edgeInsightService -> dataSyncManager "Passes anonymous summary data for synchronization"
            edgeAnalytics -> localFileAdapter "Reads local recordings for analysis"
            edgeAnalytics -> edgeRepository "Reads session and recommendation data"
            dataSyncManager -> edgeRepository "Stores summary data in Outbox"
            dataSyncManager -> localFileAdapter "Persists updated models and buffers video recordings"
            dataSyncManager -> apiGateway "Syncs anonymous data and model feedback to cloud"
            dataSyncManager -> apiGateway "Uploads session video recordings from local storage"
            edgeRepository -> edgeDB "Stores session highlights, plans, and Outbox entries"
            localMLModel -> localFileAdapter "Loads deployed model files"
            localFileAdapter -> localFileSystem "Stores recordings and deployed ML models"
            mobileGatewayProxy -> cdn "Streams video content for review and training"
            webClientApp -> cdn "Streams video content for review and training"
            coachExerciseUI -> apiGateway "Uploads technique videos"
            apiGateway -> uploadAPI "Routes upload requests"
            apiGateway -> mediaAccessAPI "Routes metadata and access requests"
            apiGateway -> dataLake "Ingests raw sensor and video data for AI R&D"
            modelTrainingService -> dataLake "Fetches training data"
            trainingJobAPI -> modelTrainingOrchestrator "Invokes retraining workflows"
            modelEvaluationAPI -> modelEvaluationService "Invokes experiment result and model version queries"
            modelTrainingOrchestrator -> trainingJob "Creates and updates training job state"
            modelTrainingOrchestrator -> trainingDataLakeAdapter "Loads training datasets and experiment inputs"
            modelTrainingOrchestrator -> dataPreprocessor "Prepares training datasets"
            modelTrainingOrchestrator -> modelTrainer "Executes model training and validation jobs"
            modelTrainingOrchestrator -> modelRegistryAdapter "Registers trained models and artifacts"
            modelEvaluationService -> modelRegistryAdapter "Loads model versions and experiment metadata"
            modelEvaluationService -> trainingJob "Loads training job outcomes for evaluation"
            dataPreprocessor -> trainingDataLakeAdapter "Requests raw training datasets"
            modelTrainer -> dataPreprocessor "Uses preprocessed data"
            trainingDataLakeAdapter -> dataLake "Loads raw sensor data and experiment inputs"
            modelRegistryAdapter -> modelRegistry "Registers trained models and loads version metadata"
            apiGateway -> trainingJobAPI "Routes retraining job and experiment execution requests"
            apiGateway -> modelEvaluationAPI "Routes model evaluation and experiment query requests"
            modelRegistry -> dataSyncManager "Deploys updated models to Edge [Downstream]"
            modelRegistry -> modelTrainingUI "Provides versioned models for evaluation"
            fitnessUser -> trainingSessionUI "Uses for training"
            fitnessUser -> analyticsUI "Reviews performance and achievements"
            fitnessUser -> recommendationsUI "Reviews AI-guided recommendations"
            fitnessUser -> trainingPlansUI "Browses and selects training plans"
            fitnessUser -> userProfileUI "Manages profile and authentication"
            fitnessUser -> groupSession "Participates in group workouts"
            fitnessUser -> socialSharing "Shares achievements with community"
            fitnessUser -> userAnalyticsUI "Reviews analytics and manages account"
            fitnessCoach -> coachExerciseUI "Submits exercise and technique data"
            techSupport -> systemMonitoringUI "Monitors platform health and performance"
            rndTeam -> trendAnalysisUI "Analyzes fitness progression and technique trends"
            rndTeam -> modelTrainingUI "Manages ML model training and evaluation"
            platformOwner -> strategicAnalyticsUI "Reviews strategic business analytics"
            crmStaff -> subscriptionMgmtUI "Manages user subscriptions and customer support"
            mobileGatewayProxy -> apiGateway "Orchestrates cloud-bound requests and authentication via API Gateway"
            userProfileUI -> apiGateway "Authenticates and manages profile via Gateway"
            analyticsUI -> apiGateway "Fetches historical analytics via Gateway"
            recommendationsUI -> apiGateway "Fetches cloud-based recommendations via Gateway"
            trainingPlansUI -> apiGateway "Fetches new training plans via Gateway"
            trainingSessionUI -> mobileGatewayProxy "Starts and manages training sessions"
            analyticsUI -> mobileGatewayProxy "Requests user analytics"
            analyticsUI -> mobileDB "Caches analytics locally"
            recommendationsUI -> mobileGatewayProxy "Requests AI recommendations"
            recommendationsUI -> mobileDB "Caches recommendations locally"
            trainingPlansUI -> mobileGatewayProxy "Requests training plans"
            trainingPlansUI -> mobileDB "Caches training plans locally"
            socialSharing -> mobileGatewayProxy "Shares achievements"
            userProfileUI -> mobileGatewayProxy "Manages profile and authentication"
            groupSession -> embeddedApp "Streams group session video"
            staticContent -> webClientApp "Delivers the Angular app shell and PWA assets to the browser app"
            userAnalyticsUI -> apiGateway "Fetches user performance and trends"
            coachExerciseUI -> apiGateway "Submits exercise and technique data"
            subscriptionMgmtUI -> apiGateway "Manages subscriptions and billing"
            strategicAnalyticsUI -> apiGateway "Fetches strategic business insights"
            systemMonitoringUI -> apiGateway "Monitors system performance metrics"
            trendAnalysisUI -> apiGateway "Fetches aggregate trend data"
            modelTrainingUI -> apiGateway "Triggers retraining and reviews experiment outputs via Gateway"
            apiGateway -> registrationAPI "Routes sign-up and coach application requests"
            apiGateway -> authenticationAPI "Routes authentication requests"
            apiGateway -> profileAPI "Routes profile and identity requests"
            apiGateway -> authorizationAPI "Routes authorization requests"
            registrationAPI -> registrationService "Invokes registration use cases"
            authenticationAPI -> authenticationService "Invokes authentication use cases"
            profileAPI -> profileService "Invokes profile management use cases"
            authorizationAPI -> authorizationService "Invokes authorization use cases"
            registrationService -> userAccount "Creates and updates registered user accounts"
            registrationService -> iamRepository "Loads and stores user credentials during registration"
            registrationService -> userRegisteredPublisher "Publishes registration outcomes"
            registrationService -> subscriptionClientACL "Links new users with subscription provisioning"
            authenticationService -> iamRepository "Loads user credentials and account state"
            authenticationService -> userAccount "Validates account status before issuing tokens"
            authenticationService -> tokenProviderACL "Issues IAM tokens and refresh credentials"
            profileService -> iamRepository "Loads and stores profile updates"
            profileService -> userAccount "Applies profile and identity changes"
            authorizationService -> iamRepository "Loads roles and permissions for access checks"
            authorizationService -> userAccount "Evaluates permissions against account roles"
            iamRepository -> iamDB "Persists user profile data, credentials, roles, and tokens"
            userRegisteredPublisher -> messageBroker "Publishes UserRegistered events"
            subscriptionClientACL -> subscriptionService "Links new users to subscriptions"
            apiGateway -> subscriptionAPI "Routes subscription management and provisioning requests"
            apiGateway -> billingAPI "Routes payment processing and billing requests"
            subscriptionAPI -> subscriptionManagementService "Invokes subscription lifecycle and provisioning use cases"
            billingAPI -> paymentService "Invokes payment and billing use cases"
            subscriptionManagementService -> subscription "Creates and updates subscription state"
            subscriptionManagementService -> subscriptionRepository "Loads and stores subscriptions and renting data"
            subscriptionManagementService -> subscriptionEventPublisher "Publishes subscription lifecycle outcomes"
            paymentService -> subscription "Updates subscription status after payment decisions"
            paymentService -> stripeACL "Delegates payment processing to Stripe-compatible models"
            paymentService -> subscriptionRepository "Loads and stores billing cycles and payment results"
            paymentService -> subscriptionEventPublisher "Publishes payment lifecycle outcomes"
            subscriptionRepository -> subscriptionDB "Persists subscriptions, billing cycles, and renting state"
            subscriptionEventPublisher -> messageBroker "Publishes SubscriptionCreated and PaymentProcessed events"
            stripeACL -> stripe "Translates domain models to Stripe API"
            trainingSessionAPI -> trainingSessionService "Invokes training session lifecycle use cases"
            performanceQueryAPI -> performanceQueryService "Invokes performance history and achievement queries"
            trainingSessionService -> trainingSession "Creates and updates training session state"
            trainingSessionService -> performanceRepository "Stores session state and performance metrics"
            trainingSessionService -> achievementService "Triggers completion workflows for finished sessions"
            performanceQueryService -> performanceRepository "Loads historical performance metrics and achievements"
            achievementService -> trainingSession "Loads completed session results"
            achievementService -> achievementCalculator "Calculates achievements for completed sessions"
            achievementService -> performanceRepository "Stores awarded achievements and updated session metrics"
            achievementService -> workoutCompletedPublisher "Publishes workout completion outcomes"
            performanceRepository -> performanceDB "Persists training sessions, metrics, and achievements"
            workoutCompletedPublisher -> messageBroker "Publishes WorkoutCompleted events"
            trendQueryAPI -> trendQueryService "Invokes trend history and aggregate trend queries"
            trendEventConsumer -> trendAnalysisService "Invokes trend recalculation workflows from workout events"
            trendQueryService -> trendsRepository "Loads historical trend data and aggregate summaries"
            trendAnalysisService -> trendsRepository "Loads and stores trend state for recalculation"
            trendAnalysisService -> fitnessTrend "Applies updated trend progression to the aggregate"
            trendAnalysisService -> trendAnalyzer "Calculates new insights from completed workout data"
            trendAnalysisService -> trendAnalyzedPublisher "Publishes trend analysis outcomes"
            trendAnalyzer -> fitnessTrend "Updates trend data based on new insights"
            trendsRepository -> trendsDB "Persists trend progression and historical metrics"
            trendAnalyzedPublisher -> messageBroker "Publishes TrendAnalyzed events"
            uploadAPI -> uploadOrchestrator "Invokes upload initiation and completion workflows"
            mediaAccessAPI -> mediaAccessService "Invokes media metadata and playback access queries"
            uploadOrchestrator -> mediaMetadataManager "Registers uploaded media and creates metadata records"
            uploadOrchestrator -> mediaDataLakeAdapter "Archives raw video recordings for AI and auditing workloads"
            uploadOrchestrator -> transcoderACL "Triggers transcoding jobs for uploaded media"
            mediaAccessService -> mediaMetadataManager "Loads media metadata and access policies"
            mediaAccessService -> mediaStorageAdapter "Resolves playback locations and signed media access"
            transcodingWorkflowService -> mediaMetadataManager "Applies transcoded file locations and playback metadata"
            transcodingWorkflowService -> mediaStorageAdapter "Stores processed media files"
            transcodingWorkflowService -> cdnInvalidationAdapter "Refreshes CDN caches and delivery policies"
            transcodingWorkflowService -> mediaEventPublisher "Publishes media processing outcomes"
            transcoderACL -> transcodingWorkflowService "Reports transcoding completion and processed artifact locations"
            mediaStorageAdapter -> mediaStorage "Stores processed media files and applies storage policies"
            mediaDataLakeAdapter -> dataLake "Archives raw media recordings"
            cdnInvalidationAdapter -> cdn "Invalidates and updates cached content policies"
            mediaEventPublisher -> messageBroker "Publishes VideoProcessed events"
            analyticsEventConsumer -> eventIngestionService "Invokes event ingestion and analytics aggregation workflows"
            eventIngestionService -> dataAggregator "Aggregates domain events into analytics inputs"
            eventIngestionService -> analyticsReport "Updates report aggregates from incoming events"
            eventIngestionService -> analyticsRepository "Stores aggregated report state and analytics history"
            dataAggregator -> messageBroker "Subscribes to Domain Events (WorkoutCompleted, TrendAnalyzed, SubscriptionCreated, UserRegistered, etc.)"
            dataAggregator -> analyticsReport "Updates aggregate data for reports"
            analyticsQueryAPI -> historicalAnalyticsService "Invokes historical analytics queries"
            strategicInsightsAPI -> strategicInsightService "Invokes strategic insight queries"
            historicalAnalyticsService -> analyticsRepository "Loads historical analytics and achievement summaries"
            strategicInsightService -> analyticsRepository "Loads report summaries and strategic snapshots"
            analyticsRepository -> analyticsDB "Persists analytics reports, history, and strategic summaries"
            strategicInsightGenerator -> analyticsReport "Analyzes reports to generate insights"
            strategicAnalyticsUI -> apiGateway "Requests strategic insights"
            userAnalyticsUI -> apiGateway "Fetches historical analytics"
            apiGateway -> strategicInsightsAPI "Routes strategic insight requests"
            apiGateway -> analyticsQueryAPI "Routes historical analytics requests"
            messageBroker -> analyticsEventConsumer "Delivers domain events for analytics aggregation"
        }
    }
    views {
        systemContext smartFitnessPlatform "SystemContext" {
            include *
            autoLayout
        }
        container smartFitnessPlatform "ContainerView" {
            include *
            autoLayout
        }
        component embeddedApp "EmbeddedAppComponents" {
            include *
            include mirrorHardware
            include localFileSystem
            include edgeApp
            autoLayout
        }
        component edgeApp "EdgeAppComponents" {
            include *
            include embeddedApp
            include edgeDB
            include localFileSystem
            include apiGateway
            autoLayout
        }
        component mobileApp "MobileAppComponents" {
            include *
            include fitnessUser
            include edgeApp
            include apiGateway
            include mobileDB
            include embeddedApp
            autoLayout
        }
        component website "WebsiteComponents" {
            include *
            include visitor
            include webClientApp
            autoLayout
        }
        component webClientApp "WebClientAppComponents" {
            include *
            include visitor
            include fitnessUser
            include fitnessCoach
            include techSupport
            include rndTeam
            include platformOwner
            include crmStaff
            include apiGateway
            include website
            autoLayout
        }
        component iamService "IAMServiceComponents" {
            include *
            include visitor
            include fitnessUser
            include fitnessCoach
            include techSupport
            include rndTeam
            include platformOwner
            include crmStaff
            include mobileApp
            include webClientApp
            include website
            include apiGateway
            include iamDB
            include messageBroker
            include subscriptionService
            autoLayout
        }
        component performanceService "PerformanceServiceComponents" {
            include *
            include apiGateway
            include performanceDB
            include messageBroker
            autoLayout
        }
        component trendsService "TrendsServiceComponents" {
            include *
            include apiGateway
            include trendsDB
            include messageBroker
            autoLayout
        }
        component subscriptionService "SubscriptionServiceComponents" {
            include *
            include crmStaff
            include fitnessUser
            include stripe
            include subscriptionDB
            include messageBroker
            include apiGateway
            include iamService
            autoLayout
        }
        component analyticsService "AnalyticsServiceComponents" {
            include *
            include platformOwner
            include fitnessUser
            include messageBroker
            include analyticsDB
            include apiGateway
            include webClientApp
            autoLayout
        }
        component modelTrainingService "ModelTrainingServiceComponents" {
            include *
            include dataLake
            include modelRegistry
            include apiGateway
            include webClientApp
            autoLayout
        }
        component mediaService "MediaServiceComponents" {
            include *
            include mediaStorage
            include cdn
            include dataLake
            include messageBroker
            include apiGateway
            include edgeApp
            include webClientApp
            autoLayout
        }
        styles {
            element "Element" {
            color darkcyan
            stroke darkcyan
            strokeWidth 7
            shape RoundedBox
            }
            element "Person" {
                shape Person
            }
            element "Visitor" {
                shape Person
                background gray
                stroke gray
                color white
            }
            element "Software System" {

            }
            element "Container" {

            }
            element "Database" {
                shape Cylinder
            }
            element "Microservice" {
                shape Hexagon
            }
            element "CoreContext" {
                background #ddffdd
            }
            element "SupportingContext" {
                background #ffffdd
            }
            element "GenericContext" {
                background #ddddff
            }
            element "CommodityContext" {
                background #eeeeee
            }
            element "ACL" {
                shape Component
                background #f8f8f8
                stroke #cccccc
            }
            element "MobileApp" {
                shape MobileDeviceLandscape
            }
            element "FileSystem" {
                shape Folder
            }
            element "StaticContent" {
                shape Folder
            }
            element "MessageBroker" {
                shape Pipe
                background #f3f2f1
            }
            element "IoT" {
                shape RoundedBox
            }
            element "Browser" {
                shape WebBrowser
            }
            element "Component" {

            }
            element "Facade" {

            }
            element "UI" {

            }
            element "Interface" {
                background #fff2cc
            }
            element "Application" {
                background #cfe2f3
            }
            element "DomainAggregate" {
                background #d9ead3
            }
            element "DomainService" {
                background #d0e0e3
            }
            element "Infrastructure" {
                background #f4cccc
            }
            element "External" {
                color white
                stroke darkgray
                background darkgray
            }
            element "Hardware" {

            }
        }
    }
}
