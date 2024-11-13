class Theme {
  static bool isDarkMode = false;
  static changeTheme() {
    isDarkMode = !isDarkMode;
  }
  static getTheme() {
    if (isDarkMode) {
      return 'dark';
    } else {
      return 'light';
    }
  }

}