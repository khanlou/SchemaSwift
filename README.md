# SchemaSwift

A Swift port of [schemats](https://github.com/SweetIQ/schemats/). Generates Swift structs from your PostgreSQL schema.

SchemaSwift is intended to be run as a command line tool.

```
SchemaSwift --url <your postgres url> \
    --override users.email=Email \
    --swift-namespace DB \
    --protocols "Equatable, Hashable, Identifiable"
```

## Available options:

### url

Required, a URL to a Postgres instance. 

### output, o
The location of the file containing the output. Will output to stdout if a file is not specified.

### schema
The schema in the database to generate models for. Will default to "public" if not specified.

### protocols

A list of comma separated protocols to apply to each record struct. Codable conformance is always included. Will default to adding \"Equatable, Hashable\" if not specified.

### swift-namespace
An empty enum that acts as a namespace that all types will go inside. If not specified, types will not be placed inside an enum.

### override
Overrides for the generated types. Must be in the format `table.column=Type`. May include multiple overrides.
