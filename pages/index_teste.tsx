import Avatar from '../src/components/Avatar/Avatar'
import LinkTree from '../src/components/LinkTree/LinkTree'

import styles from '../styles/Home.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <Avatar />
      <h1 className={styles.title}>B0BD3V</h1>
      <LinkTree />
    </main>
  )
}
