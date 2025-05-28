const alphaVersion = bool.fromEnvironment('ALPHA_VERSION');
const appVersion = String.fromEnvironment('BUILD_VERSION', defaultValue: 'Dev');
const buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: '2024-03-12');
const repoAuthor = String.fromEnvironment('REPO_AUTHOR', defaultValue: 'GhostenEditor');
const repoName = String.fromEnvironment('REPO_NAME', defaultValue: 'Ghosten-Player');
const updateUrl = 'https://api.github.com/repos/$repoAuthor/$repoName/releases';
const ua =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Safari/537.36';
const headerUserAgent = 'User-Agent';
const assetsLogo = 'assets/common/images/logo.png';
const assetsNoData = 'assets/common/images/no data.png';
const appName = 'Ghosten Player';
const double kQrSize = 240;
