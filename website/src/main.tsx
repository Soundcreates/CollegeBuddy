import { FormEvent, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

const latestReleaseUrl = 'https://github.com/Soundcreates/CollegeBuddy/releases/latest';

const screenshots = [
  { file: 'signin.png', label: 'A softer start', title: 'One calm place to begin' },
  { file: 'inbox.png', label: 'Focused inbox', title: 'See what deserves your attention' },
  { file: 'classroom.png', label: 'Classroom, clearer', title: 'Keep every course and deadline close' },
];

function Leaf({ className = '' }: { className?: string }) {
  return <span className={`leaf ${className}`} aria-hidden="true" />;
}

function WaitlistForm() {
  const [joined, setJoined] = useState(false);

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setJoined(true);
  }

  if (joined) return <p className="form-success" role="status">You’re on the list. We’ll be in touch.</p>;

  return (
    <form className="waitlist-form" onSubmit={submit}>
      <label className="sr-only" htmlFor="email">Email address</label>
      <input id="email" name="email" type="email" autoComplete="email" placeholder="your@email.com" required />
      <button type="submit">Join the waitlist <span aria-hidden="true">→</span></button>
    </form>
  );
}

function App() {
  return (
    <main>
      <section className="hero" id="top">
        <Leaf className="leaf-one" /><Leaf className="leaf-two" /><Leaf className="leaf-three" />
        <nav className="nav wrap" aria-label="Main navigation">
          <a className="brand" href="#top"><img className="brand-mark" src="/branding/collegebuddy-mark.png" alt="" aria-hidden="true" /> CollegeBuddy</a>
          <div className="nav-links"><a href="#how-it-helps">How it helps</a><a href="#inside">Inside the app</a></div>
          <a className="nav-cta" href="#waitlist">Join waitlist</a>
        </nav>
        <div className="hero-content wrap">
          <div className="hero-copy">
            <p className="eyebrow">A calmer way through college</p>
            <h1>Let your college life <em>grow</em>, not pile up.</h1>
            <p className="lede">CollegeBuddy gathers the emails, coursework, and small next steps that fill your day—so you can make room for the work that matters.</p>
            <a className="button button-dark" href={latestReleaseUrl} target="_blank" rel="noreferrer">Download app <span aria-hidden="true">↗</span></a>
            <p className="note">Built for students. Designed for a little more breathing room.</p>
          </div>
          <div className="hero-phone" aria-label="CollegeBuddy sign in screen">
            <div className="phone-shell"><img src="/screenshots/signin.png" alt="CollegeBuddy sign-in screen" /></div>
            <span className="hero-orbit orbit-a" aria-hidden="true">✦</span><span className="hero-orbit orbit-b" aria-hidden="true">✳</span>
          </div>
        </div>
      </section>

      <section className="intro wrap" id="how-it-helps">
        <p className="eyebrow">Your academic ecosystem</p>
        <h2>Less chasing. More <em>showing up.</em></h2>
        <p>College moves fast. CollegeBuddy turns its most important signals into a gentle, useful rhythm—without another complicated system to maintain.</p>
      </section>

      <section className="feature-grid wrap">
        <article><span className="feature-icon">✉</span><h3>Your focused inbox</h3><p>Important college messages, gathered into a quieter space that is easier to scan.</p></article>
        <article><span className="feature-icon">⌁</span><h3>Deadlines in view</h3><p>Bring your Google Classroom assignments and course work together before they become a scramble.</p></article>
        <article><span className="feature-icon">✦</span><h3>A helpful nudge</h3><p>Get useful assignment context when you need a place to start—not another blank page.</p></article>
      </section>

      <section className="product" id="inside">
        <Leaf className="leaf-four" /><Leaf className="leaf-five" />
        <div className="wrap product-heading"><p className="eyebrow">Inside CollegeBuddy</p><h2>Your day, in a more <em>natural flow.</em></h2></div>
        <div className="showcase wrap">
          {screenshots.map((shot, index) => (
            <article className={`showcase-card card-${index + 1}`} key={shot.file}>
              <div className="phone-shell"><img src={`/screenshots/${shot.file}`} alt={`CollegeBuddy ${shot.label.toLowerCase()} screen`} /></div>
              <div><p className="eyebrow">0{index + 1} · {shot.label}</p><h3>{shot.title}</h3></div>
            </article>
          ))}
        </div>
      </section>

      <section className="closing wrap" id="waitlist">
        <div><p className="eyebrow">A fresh start is close</p><h2>Make space for what you’re here to <em>learn.</em></h2><p>Join the CollegeBuddy waitlist for launch updates.</p></div>
        <WaitlistForm />
      </section>

      <footer className="footer wrap"><a className="brand" href="#top"><img className="brand-mark" src="/branding/collegebuddy-mark.png" alt="" aria-hidden="true" /> CollegeBuddy</a><span>For students finding their flow.</span></footer>
    </main>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
