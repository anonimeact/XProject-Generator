/// Dockerfile for GitLab CI with Flutter + Fastlane.
class DockerfileTemplate {
  static String content() {
    return '''
FROM ghcr.io/cirruslabs/flutter:stable

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \\
    ruby-full build-essential \\
    && rm -rf /var/lib/apt/lists/*

RUN gem install fastlane --no-document

WORKDIR /build
'''.trim();
  }
}
