import React from 'react';
import Login from 'oberd/login-js';

let Home = React.createClass({
    propTypes: {
        user: React.PropTypes.object
    },
    getDefaultProps: function() {
        return { user: Login.user() };
    },
    render: function() {
        var name = this.props.user.get('name');
        return (
            <article>
                Welcome to Oberd {name}
            </article>
        );
    }
});

export default Home;
