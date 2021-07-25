import styled from 'styled-components';

export const ul = styled.ul`
  width: 95vw;
  max-width: 37rem;
  padding: 0.5rem 1.5rem;
  margin: 0;
  list-style: none;
`

export const li = styled.li`
  background-color: #FFFFFF;
  border-radius: 0.5rem;
  box-shadow: 0 0.5em 1em -0.125em rgba(10, 10, 10, 0.1), 0 0 0 1px rgba(10, 10, 10, 0.02);
  transition: transform 200ms ease-in;
  margin-top: 2rem;

  :first-child {
    margin-top: 0;
  }

  :hover {
    transform: scale(1.05);
    cursor: pointer;
  }
`

export const content = styled.div`
  display: flex;
`
export const media = styled.div`
  display: flex;
  align-items: center;
  padding: 1em;
`
export const github = styled.svg`
  path {
    fill: #232323;
  }
`

export const linkedin = styled.svg`
  path {
    fill: #232323;
  }
`

export const data = styled.div`
  padding: 1em 0 1em 0;
`

export const title = styled.span``

export const description = styled.p`
  margin: 0.5em 0 0 0;
`
