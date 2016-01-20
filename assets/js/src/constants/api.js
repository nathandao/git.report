let baseUrl = 'http://service.git.report';
if (process.env.NODE_ENV === 'localdev') {
  baseUrl = 'http://localhost:8080';
}
export const REPOS = ['wordpress', 'drupal', 'php', 'ruby', 'ezplatform'];
export const API_INIT_DATA = `${baseUrl}/api/init_data`;
export const API_REPO_LIST = `${baseUrl}/api/repo_list`;
export const API_OVERVIEW = `${baseUrl}/api/overview`;
export const API_COMMITS = `${baseUrl}/api/commits`;
