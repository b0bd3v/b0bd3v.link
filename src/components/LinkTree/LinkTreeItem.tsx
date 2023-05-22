import React from 'react';

import * as styled from './LinkTree.styles'

const LinkTreeItem = ({ href, title, description, icon }) => <a href={href} target="_blank" rel="noreferrer">
    <styled.content>
    <styled.media>
      <div>
        {icon}
      </div>
    </styled.media>
    <styled.data>
      <styled.title>{title}</styled.title>
      <styled.description>
        {description}
      </styled.description>
    </styled.data>
    </styled.content>
  </a>

export default LinkTreeItem