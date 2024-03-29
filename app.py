from flask import Flask, render_template

frontend_app = Flask(__name__)

@frontend_app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    frontend_app.run(debug=True, host='0.0.0.0', port=80)  # Run the frontend app on port 5000
