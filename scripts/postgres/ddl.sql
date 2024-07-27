CREATE SCHEMA ai_road_map;

CREATE TABLE "ai_road_map"."key_value_format" (
                                                  "id" uuid PRIMARY KEY,
                                                  "payload_validator_name" uuid NOT NULL,
                                                  "key" varchar,
                                                  "type" varchar,
                                                  "match" varchar,
                                                  "required" boolean,
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
                                                 "response_validation_name" varchar,
                                                 "metadata_validation_name" varchar,
                                                 "research_config_id" uuid,
                                                 "question_template" varchar,
                                                 "step" integer,
                                                 PRIMARY KEY ("research_config_id", "step"),
                                                 "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "ai_road_map"."prompt_road_map_config" (
                                                        "id" uuid PRIMARY KEY,
                                                        "name" varchar,
                                                        "total_steps" integer,
                                                        "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                        "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "ai_road_map"."prompt_road_map_config_execution" (
                                                                  "id" uuid PRIMARY KEY,
                                                                  "total_steps" integer,
                                                                  "step_in_execution" integer,
                                                                  "metadata" json,
                                                                  "prompt_road_map_config_id" uuid,
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
    ADD FOREIGN KEY ("research_config_id")
        REFERENCES "ai_road_map"."prompt_road_map_config" ("id");

ALTER TABLE "ai_road_map"."prompt_road_map_config_execution"
    ADD FOREIGN KEY ("prompt_road_map_config_id")
        REFERENCES "ai_road_map"."prompt_road_map_config" ("id");

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