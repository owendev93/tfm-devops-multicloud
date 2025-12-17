pipeline {
  agent none

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30'))
    ansiColor('xterm')
    timeout(time: 60, unit: 'MINUTES')
  }

  parameters {
    choice(name: 'ENV', choices: ['staging', 'prod'], description: 'Entorno objetivo (staging/prod). Producción requiere aprobación.')
    choice(name: 'TARGET', choices: ['both', 'eks', 'aks'], description: 'Destino de despliegue multinube.')
    string(name: 'APP_NAME', defaultValue: 'tfm-app', description: 'Nombre lógico de la aplicación.')
    string(name: 'IMAGE_TAG', defaultValue: '', description: 'Opcional. Si vacío, se usa TAG=shortSHA-buildNumber.')
    booleanParam(name: 'RUN_DAST', defaultValue: true, description: 'Ejecutar pruebas dinámicas (baseline).')
  }

  environment {
    // TODO: Registry “fuente única de verdad” (recomendado)
    // Ejemplos:
    // - GHCR: ghcr.io/org/repo
    // - ACR: myregistry.azurecr.io/tfm
    // - ECR: <account>.dkr.ecr.<region>.amazonaws.com/tfm
    REGISTRY_REPO = "TODO_REGISTRY_REPO"

    // Namespaces por entorno
    NS_STAGING = "staging"
    NS_PROD    = "prod"

    // Helm chart path dentro del repo
    HELM_CHART_DIR = "deploy/helm/${APP_NAME}"

    // Values por proveedor (mínimas diferencias)
    VALUES_EKS = "deploy/helm/values-eks.yaml"
    VALUES_AKS = "deploy/helm/values-aks.yaml"

    // Quality gates (umbral de ejemplo; ajusta a tu criterio)
    MAX_CRITICAL_VULNS = "0"
    MAX_HIGH_VULNS     = "0"
  }

  stages {

    stage('Source: Checkout') {
      agent { label 'linux-docker' } // TODO: etiqueta de tu agente
      steps {
        checkout scm
        sh '''
          set -e
          echo "Commit: $(git rev-parse HEAD)"
          echo "Branch: ${BRANCH_NAME}"
          git status --porcelain
        '''
      }
    }

    stage('Prepare: Versioning & Metadata') {
      agent { label 'linux-docker' }
      steps {
        script {
          def sha = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
          def tag = params.IMAGE_TAG?.trim()
          if (!tag) {
            tag = "${sha}-${env.BUILD_NUMBER}"
          }
          env.GIT_SHA_SHORT = sha
          env.IMAGE_TAG_RESOLVED = tag
          env.IMAGE_REF_TAG = "${env.REGISTRY_REPO}:${env.IMAGE_TAG_RESOLVED}"
          echo "IMAGE_REF_TAG: ${env.IMAGE_REF_TAG}"
        }
      }
    }

    stage('CI: Unit Tests & Coverage') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Ejecutar unit tests aquí (Node/Java/Python según app)"
          # Ejemplos:
          # npm ci && npm test -- --ci
          # mvn -B test
          # pytest -q
        '''
      }
      post {
        always {
          // TODO: publicar reportes si existen
          // junit 'reports/junit.xml'
          // publishHTML(...) etc.
          echo "Publicar artefactos de test/cobertura (si aplica)."
        }
      }
    }

    stage('Security: Secret Scanning (gitleaks)') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "Ejecutando secret scan (gitleaks/trufflehog)..."
          # TODO: añade gitleaks en tu agente o usa contenedor
          # gitleaks detect --source . --no-git --redact --report-format json --report-path gitleaks.json
          echo "TODO: Integrar gitleaks real (recomendado)."
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f gitleaks.json && cp gitleaks.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Security: SAST (Semgrep/Sonar) + Quality Gate') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Ejecutar SAST aquí"
          # Semgrep ejemplo:
          # semgrep ci --json --output semgrep.json
          #
          # SonarQube ejemplo:
          # sonar-scanner -Dsonar.projectKey=... -Dsonar.host.url=... -Dsonar.login=...
          #
          echo "TODO: Aplicar Quality Gate. Si falla => exit 1"
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f semgrep.json && cp semgrep.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Security: SCA (Dependencies)') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Ejecutar SCA aquí (dependencias)"
          # Ejemplos:
          # npm audit --json > npm-audit.json || true
          # osv-scanner --format json -o osv.json .
          #
          echo "TODO: Definir umbral CVEs. Si hay críticas/altas => exit 1"
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f npm-audit.json && cp npm-audit.json artifacts/ || true'
          sh 'test -f osv.json && cp osv.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Build: Container Image') {
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'TODO_REGISTRY_CREDS', usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')
        ]) {
          sh '''
            set -e
            echo "${REG_PASS}" | docker login -u "${REG_USER}" --password-stdin $(echo "${REGISTRY_REPO}" | awk -F/ '{print $1}')
            docker build -t "${IMAGE_REF_TAG}" .
            docker push "${IMAGE_REF_TAG}"
          '''
        }
      }
    }

    stage('Security: Container Scan (Trivy/Grype)') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Escaneo de imagen con Trivy/Grype"
          # Trivy ejemplo:
          # trivy image --format json -o trivy.json "${IMAGE_REF_TAG}" || true
          #
          # TODO: parsear trivy.json para aplicar umbrales (crit/high)
          echo "TODO: Aplicar gates: crit=${MAX_CRITICAL_VULNS}, high=${MAX_HIGH_VULNS}"
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f trivy.json && cp trivy.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Supply Chain: SBOM (CycloneDX/SPDX)') {
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Generar SBOM"
          # Ejemplos:
          # cyclonedx-npm --output-file sbom.json
          # syft "${IMAGE_REF_TAG}" -o cyclonedx-json > sbom.json
          echo "TODO: Guardar sbom.json como artefacto"
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f sbom.json && cp sbom.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Supply Chain: Sign Image (Cosign)') {
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          file(credentialsId: 'TODO_COSIGN_KEY', variable: 'COSIGN_KEY_FILE'),
          string(credentialsId: 'TODO_COSIGN_PASSWORD', variable: 'COSIGN_PASSWORD')
        ]) {
          sh '''
            set -e
            echo "TODO: Firmando imagen con cosign..."
            # cosign sign --key "${COSIGN_KEY_FILE}" "${IMAGE_REF_TAG}"
            echo "TODO: Verificar firma (pre-deploy) con cosign verify..."
          '''
        }
      }
    }

    stage('Resolve: Image Digest (Immutability)') {
      agent { label 'linux-docker' }
      steps {
        script {
          def digest = sh(
            script: "docker inspect --format='{{index .RepoDigests 0}}' ${env.IMAGE_REF_TAG}",
            returnStdout: true
          ).trim()
          if (!digest) {
            error("No se pudo resolver RepoDigest para la imagen ${env.IMAGE_REF_TAG}")
          }
          env.IMAGE_REF_DIGEST = digest
          echo "IMAGE_REF_DIGEST: ${env.IMAGE_REF_DIGEST}"
        }
      }
    }

    stage('Deploy: Staging (EKS)') {
      when { expression { return params.ENV == 'staging' && (params.TARGET == 'both' || params.TARGET == 'eks') } }
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          file(credentialsId: 'TODO_KUBECONFIG_EKS', variable: 'KUBECONFIG')
        ]) {
          sh '''
            set -e
            echo "Desplegando en EKS (staging) por DIGEST..."
            helm upgrade --install "${APP_NAME}" "${HELM_CHART_DIR}" \
              -n "${NS_STAGING}" --create-namespace \
              -f "${VALUES_EKS}" \
              --set image.digest="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $2}')" \
              --set image.repository="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $1}')"
            kubectl -n "${NS_STAGING}" rollout status deploy/"${APP_NAME}" --timeout=180s
          '''
        }
      }
    }

    stage('Deploy: Staging (AKS)') {
      when { expression { return params.ENV == 'staging' && (params.TARGET == 'both' || params.TARGET == 'aks') } }
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          file(credentialsId: 'TODO_KUBECONFIG_AKS', variable: 'KUBECONFIG')
        ]) {
          sh '''
            set -e
            echo "Desplegando en AKS (staging) por DIGEST..."
            helm upgrade --install "${APP_NAME}" "${HELM_CHART_DIR}" \
              -n "${NS_STAGING}" --create-namespace \
              -f "${VALUES_AKS}" \
              --set image.digest="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $2}')" \
              --set image.repository="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $1}')"
            kubectl -n "${NS_STAGING}" rollout status deploy/"${APP_NAME}" --timeout=180s
          '''
        }
      }
    }

    stage('Validation: Smoke Tests (Staging)') {
      when { expression { return params.ENV == 'staging' } }
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Smoke tests contra endpoints staging EKS y AKS"
          # Ejemplo:
          # curl -fsS https://staging-eks.tu-dominio/health
          # curl -fsS https://staging-aks.tu-dominio/health
        '''
      }
    }

    stage('Security: DAST (Baseline)') {
      when { expression { return params.ENV == 'staging' && params.RUN_DAST } }
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Ejecutar DAST baseline (OWASP ZAP) contra staging"
          # Ejemplo:
          # zap-baseline.py -t https://staging-eks.tu-dominio -J zap-eks.json || true
          # zap-baseline.py -t https://staging-aks.tu-dominio -J zap-aks.json || true
          echo "TODO: Aplicar criterio de aceptación (sin alertas High)."
        '''
      }
      post {
        always {
          sh 'mkdir -p artifacts && true'
          sh 'test -f zap-eks.json && cp zap-eks.json artifacts/ || true'
          sh 'test -f zap-aks.json && cp zap-aks.json artifacts/ || true'
          archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
      }
    }

    stage('Approval: Promote to Production') {
      when { expression { return params.ENV == 'prod' } }
      agent none
      steps {
        input message: "Aprobación requerida: ¿Promover imagen ${env.IMAGE_REF_DIGEST} a PRODUCCIÓN en ${params.TARGET}?"
      }
    }

    stage('Deploy: Production (EKS)') {
      when { expression { return params.ENV == 'prod' && (params.TARGET == 'both' || params.TARGET == 'eks') } }
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          file(credentialsId: 'TODO_KUBECONFIG_EKS', variable: 'KUBECONFIG')
        ]) {
          sh '''
            set -e
            echo "Desplegando en EKS (prod) por DIGEST..."
            helm upgrade --install "${APP_NAME}" "${HELM_CHART_DIR}" \
              -n "${NS_PROD}" --create-namespace \
              -f "${VALUES_EKS}" \
              --set image.digest="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $2}')" \
              --set image.repository="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $1}')"
            kubectl -n "${NS_PROD}" rollout status deploy/"${APP_NAME}" --timeout=240s
          '''
        }
      }
    }

    stage('Deploy: Production (AKS)') {
      when { expression { return params.ENV == 'prod' && (params.TARGET == 'both' || params.TARGET == 'aks') } }
      agent { label 'linux-docker' }
      steps {
        withCredentials([
          file(credentialsId: 'TODO_KUBECONFIG_AKS', variable: 'KUBECONFIG')
        ]) {
          sh '''
            set -e
            echo "Desplegando en AKS (prod) por DIGEST..."
            helm upgrade --install "${APP_NAME}" "${HELM_CHART_DIR}" \
              -n "${NS_PROD}" --create-namespace \
              -f "${VALUES_AKS}" \
              --set image.digest="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $2}')" \
              --set image.repository="$(echo ${IMAGE_REF_DIGEST} | awk -F@ '{print $1}')"
            kubectl -n "${NS_PROD}" rollout status deploy/"${APP_NAME}" --timeout=240s
          '''
        }
      }
    }

    stage('Post-Deploy: Verification & Rollback Strategy') {
      when { expression { return params.ENV == 'prod' } }
      agent { label 'linux-docker' }
      steps {
        sh '''
          set -e
          echo "TODO: Verificación post-deploy (healthchecks) y plan de rollback"
          echo "Ejemplo rollback Helm: helm rollback ${APP_NAME} <REVISION> -n ${NS_PROD}"
        '''
      }
    }
  }

  post {
    always {
      echo "Archivando metadatos de build para trazabilidad..."
      sh '''
        mkdir -p artifacts
        cat > artifacts/build-metadata.txt <<EOF
        BUILD_NUMBER=${BUILD_NUMBER}
        GIT_SHA_SHORT=${GIT_SHA_SHORT}
        IMAGE_REF_TAG=${IMAGE_REF_TAG}
        IMAGE_REF_DIGEST=${IMAGE_REF_DIGEST}
        TARGET=${TARGET}
        ENV=${ENV}
        EOF
      '''
      archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: false
    }
    failure {
      echo "Pipeline fallido: revisar gates y evidencias para memoria."
    }
  }
}
