# Realtime Collaborative Whiteboard

Draw, brainstorm, and play games together in real-time on a shared digital canvas. Built with Flutter and Supabase.

## About The Project

This project is a fun, real-time collaborative whiteboard designed for users to draw together with their friends on a single canvas. You can share an invite key to start a session and see everyone's creations appear instantly. It's a great tool for quick brainstorming sessions or for playing simple games like Tic-Tac-Toe and Pictionary.

The core of the application is powered by Supabase's Realtime capabilities, ensuring a smooth and synchronous experience for all users.

### Key Features

- **Real-Time Sync**: Drawings appear instantly for all participants in a session, powered by Supabase Realtime subscriptions.
- **Multi-User Collaboration**: Easily create a new whiteboard and share a unique 6-digit invite key to have friends join your canvas.
- **Customizable Drawing Tools**: Express your ideas with a color picker and an adjustable stroke-size slider.
- **Simple & Fun Interface**: A clean and intuitive UI makes it perfect for quick games, collaborative doodling, or simple brainstorming.

### Tech Stack

- **Framework**: Flutter
- **Backend**: Supabase (Authentication, Realtime, Postgres Database)
- **State Management**: Flutter Riverpod
- **Platform**: Android & iOS

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Git: [Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation & Setup

1.  **Set up Supabase:**

    - Go to [Supabase](https://supabase.com/) and create a new project.
    - Navigate to the **SQL Editor** in your Supabase project dashboard.
    - Create a new query and paste the following SQL code to set up the necessary tables. Click **Run**.

      ```sql
      -- Create the whiteboards table
      CREATE TABLE whiteboards (
        whiteboard_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
        title TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        invite_key TEXT NOT NULL UNIQUE
      );

      -- Create the strokes table
      CREATE TABLE strokes (
        stroke_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
        whiteboard_id BIGINT REFERENCES whiteboards(whiteboard_id) ON DELETE CASCADE,
        color BIGINT NOT NULL,
        size DOUBLE PRECISION NOT NULL,
        stroke_offset JSONB NOT NULL
      );

      -- Create the join table for users and whiteboards
      CREATE TABLE userswhiteboards (
        userwhiteboards_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        whiteboard_id BIGINT REFERENCES whiteboards(whiteboard_id) ON DELETE CASCADE
      );

      -- Enable Realtime on the tables
      ALTER PUBLICATION supabase_realtime ADD TABLE whiteboards;
      ALTER PUBLICATION supabase_realtime ADD TABLE strokes;
      ALTER PUBLICATION supabase_realtime ADD TABLE userswhiteboards;
      ```

2.  **Set up Environment Variables:**

    - Create a file named `.env` in the root of your project.
    - Add your Supabase Project URL and Anon Key to this file. You can find these in your Supabase project's **Settings > API**.
    - Use this template:
      ```env
      # .env.example
      SUPABASE_URL="[https://your-project-url.supabase.co](https://your-project-url.supabase.co)"
      SUPABASE_ANON_KEY="your-supabase-anon-key"
      ```

3.  **Run the App:**
    ```sh
    flutter pub get
    flutter run
    ```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
