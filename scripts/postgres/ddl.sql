CREATE SCHEMA ai_road_map;

CREATE TABLE "ai_road_map"."key_value_format" (
                                                  "id" uuid PRIMARY KEY,
                                                  "payload_validator_name" varchar NOT NULL,
                                                  "key" varchar  NOT NULL,
                                                  "type" varchar  NOT NULL,
                                                  "match" varchar,
                                                  "required" boolean NOT NULL,
                                                  "children_payload_validator_name" varchar,
                                                  "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "ai_road_map"."payload_validator" (
                                                   "name" varchar PRIMARY KEY,
                                                   "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                   "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE "ai_road_map"."key_value_format"
    ADD FOREIGN KEY ("payload_validator_name")
        REFERENCES "ai_road_map"."payload_validator" ("name");

ALTER TABLE "ai_road_map"."key_value_format"
    ADD FOREIGN KEY ("children_payload_validator_name")
        REFERENCES "ai_road_map"."payload_validator" ("name");

CREATE TABLE "ai_road_map"."prompt_road_map" (
                                                 "response_validation_name" varchar NOT NULL,
                                                 "metadata_validation_name" varchar NOT NULL,
                                                 "prompt_road_map_config_name" varchar NOT NULL,
                                                 "question_template" varchar,
                                                 "step" integer NOT NULL,
                                                 PRIMARY KEY ("prompt_road_map_config_name", "step"),
                                                 "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "ai_road_map"."prompt_road_map_config" (
                                                        "name" varchar PRIMARY KEY,
                                                        "total_steps" integer,
                                                        "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                        "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "ai_road_map"."prompt_road_map_config_execution" (
                                                                  "id" uuid PRIMARY KEY,
                                                                  "total_steps" integer NOT NULL,
                                                                  "step_in_execution" integer NOT NULL,
                                                                  "metadata" json NOT NULL,
                                                                  "prompt_road_map_config_name" varchar NOT NULL,
                                                                  "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                                  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE "ai_road_map"."prompt_road_map"
    ADD FOREIGN KEY ("response_validation_name")
        REFERENCES "ai_road_map"."payload_validator" ("name");

ALTER TABLE "ai_road_map"."prompt_road_map"
    ADD FOREIGN KEY ("metadata_validation_name")
        REFERENCES "ai_road_map"."payload_validator" ("name");

ALTER TABLE "ai_road_map"."prompt_road_map"
    ADD FOREIGN KEY ("prompt_road_map_config_name")
        REFERENCES "ai_road_map"."prompt_road_map_config" ("name");

ALTER TABLE "ai_road_map"."prompt_road_map_config_execution"
    ADD FOREIGN KEY ("prompt_road_map_config_name")
        REFERENCES "ai_road_map"."prompt_road_map_config" ("name");

-- AUTO Update at function
CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- AUTO Update at triggers
CREATE TRIGGER update_key_value_format_updated_at
    BEFORE UPDATE ON "ai_road_map"."key_value_format"
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payload_validator_updated_at
    BEFORE UPDATE ON "ai_road_map"."payload_validator"
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prompt_road_map_updated_at
    BEFORE UPDATE ON "ai_road_map"."prompt_road_map"
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prompt_road_map_config_updated_at
    BEFORE UPDATE ON "ai_road_map"."prompt_road_map_config"
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prompt_road_map_config_execution_updated_at
    BEFORE UPDATE ON "ai_road_map"."prompt_road_map_config_execution"
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();