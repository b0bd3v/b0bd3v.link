import Head from 'next/head'

import Avatar from '../src/components/Avatar/Avatar'
import LinkTree from '../src/components/LinkTree/LinkTree'

import styles from '../styles/Home.module.css'

export default function Home() {
  return (
    <div className={styles.container}>
      <Head>
        <title>b0bd3v - Roberto Martins da Silva</title>
        <meta name="description" content="This is the personal website of Roberto Martins da Silva - B0bd3v" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <Avatar />
        <h1 className={styles.title}>B0BD3V</h1>
        <LinkTree />
      </main>
    </div>
  )
}
