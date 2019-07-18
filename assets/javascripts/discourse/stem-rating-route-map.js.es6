export default {
  resource: 'admin.adminPlugins',
  path: '/plugins',
  map() {
    this.route('stem', function() {
    	this.route('/');
    	this.route('list');
    });
    this.route('stemcat');
  }
};