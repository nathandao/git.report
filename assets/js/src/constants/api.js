let baseUrl = 'http://localhost:8080';

if (process.env.NODE_ENV === 'production') {
  baseUrl = '';
}

export const REPOS = ['ginatra', 'wp_calypso', 'wordpress', 'drupal'];
export const API_INIT_DATA = `${baseUrl}/api/init_data`;
export const API_REPO_LIST = `${baseUrl}/api/repo_list`;
export const API_OVERVIEW = `${baseUrl}/api/overview`;
export const API_COMMITS = `${baseUrl}/api/commits`;
