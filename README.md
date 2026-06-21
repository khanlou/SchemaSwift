# SchemaSwift

A Swift port of [schemats](https://github.com/SweetIQ/schemats/). Generates Swift structs from your PostgreSQL schema.

SchemaSwift is intended to be run as a command line tool.

```
SchemaSwift --url <your postgres url> \
    --override users.email=Email \
    --swift-namespace DB \
    --protocols "Equatable, Hashable, Identifiable"
```

You can also run SchemaSwift from an individual Swift package by adding SchemaSwift as a package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/khanlou/SchemaSwift.git", from: "1.0.0"),
]
```

Add a `.schemaswift.json` file to the project's root directory. Config files must include `output`. To keep database credentials out of git, reference an environment variable instead of storing the URL directly:

```json
{
  "url": "${SCHEMASWIFT_DATABASE_URL}",
  "output": "Sources/App/Generated/Database.swift",
  "schema": "public",
  "protocols": ["Equatable", "Hashable", "Identifiable"],
  "swiftNamespace": "DB",
  "trimTrailingWhitespace": true,
  "overrides": [
    "users.email=Email"
  ]
}
```

Then add the real URL to `.env.local`, which is ignored by git:

```sh
SCHEMASWIFT_DATABASE_URL=postgres://user:password@localhost:5432/database
```

Then run:

```
swift package plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all:5432 \
    schemaswift
```

The Swift package plugin automatically loads `.env.local` into SchemaSwift's environment before running the generator.

The plugin declares network permission for the default Postgres port, `5432`. If your database URL uses a custom port, pass it when allowing network access:

```
swift package plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections 15432 \
    schemaswift
```

SchemaSwift automatically reads `.schemaswift.json` from the package directory when it exists. You can also pass a specific config file:

```
swift package plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections \
    schemaswift --config path/to/schemaswift.json
```

Command line options override values from the config file. Configured output paths are resolved relative to the config file location.

## Available options:

### config

The path to a JSON configuration file. Defaults to `.schemaswift.json` in the current directory when that file exists.

### url

The direct URL to a Postgres instance. Supports environment variable references like `${SCHEMASWIFT_DATABASE_URL}`.

### urlEnvironmentVariable

The name of an environment variable containing the Postgres URL. This is still supported, but `${SCHEMASWIFT_DATABASE_URL}` inside `url` is preferred for committed config files.

### envFile

The path to a local environment file to read before resolving `urlEnvironmentVariable`. Paths are resolved relative to the config file location. `.env` files are ignored by this repository's `.gitignore`, except for `.env.example`. When using the Swift package plugin, `.env.local` is loaded automatically.

### output, o
The location of the file containing the output. Required in JSON configuration files. For command-line only usage, SchemaSwift will output to stdout if a file is not specified.

### schema
The schema in the database to generate models for. Will default to "public" if not specified.

### protocols

A list of comma separated protocols to apply to each record struct. Codable conformance is always included. Will default to adding \"Equatable, Hashable\" if not specified.

### swift-namespace
An empty enum that acts as a namespace that all types will go inside. If not specified, types will not be placed inside an enum.

### trim-trailing-whitespace
Remove trailing spaces and tabs from each generated output line. In JSON configuration files, use `trimTrailingWhitespace`.

### override
Overrides for the generated types. Must be in the format `table.column=Type`. May include multiple overrides.
