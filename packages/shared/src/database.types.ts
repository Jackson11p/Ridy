
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "graphql_public": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "graphql":
{ Args: { "extensions"?: Json,"operationName"?: string,"query"?: string,"variables"?: Json }; Returns: Json
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"public": {
          Tables: {
            "memberships": {
                  Row: {
                    "active": boolean,"created_at": string,"id": string,"operator_id": string,"profile_id": string,"role": Database["public"]['Enums']["membership_role"],"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"created_at"?: string,"id"?: string,"operator_id": string,"profile_id": string,"role": Database["public"]['Enums']["membership_role"],"updated_at"?: string
                  }
                  Update: {
                    "active"?: boolean,"created_at"?: string,"id"?: string,"operator_id"?: string,"profile_id"?: string,"role"?: Database["public"]['Enums']["membership_role"],"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "memberships_operator_id_fkey"
      columns: ["operator_id"]
isOneToOne: false
      referencedRelation: "operators"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "memberships_profile_id_fkey"
      columns: ["profile_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"operators": {
                  Row: {
                    "active": boolean,"country": string,"created_at": string,"currency": string,"id": string,"name": string,"plan": string,"timezone": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"country": string,"created_at"?: string,"currency": string,"id"?: string,"name": string,"plan"?: string,"timezone": string,"updated_at"?: string
                  }
                  Update: {
                    "active"?: boolean,"country"?: string,"created_at"?: string,"currency"?: string,"id"?: string,"name"?: string,"plan"?: string,"timezone"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"profiles": {
                  Row: {
                    "active": boolean,"created_at": string,"full_name": string | null,"id": string,"locale": string,"phone": string | null,"push_token": string | null,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"created_at"?: string,"full_name"?: string | null,"id": string,"locale"?: string,"phone"?: string | null,"push_token"?: string | null,"updated_at"?: string
                  }
                  Update: {
                    "active"?: boolean,"created_at"?: string,"full_name"?: string | null,"id"?: string,"locale"?: string,"phone"?: string | null,"push_token"?: string | null,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"routes": {
                  Row: {
                    "active": boolean,"code": string,"created_at": string,"id": string,"operator_id": string,"school_id": string,"shift": Database["public"]['Enums']["route_shift"],"updated_at": string,"vehicle_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"code"?: string,"created_at"?: string,"id"?: string,"operator_id": string,"school_id": string,"shift": Database["public"]['Enums']["route_shift"],"updated_at"?: string,"vehicle_id": string
                  }
                  Update: {
                    "active"?: boolean,"code"?: string,"created_at"?: string,"id"?: string,"operator_id"?: string,"school_id"?: string,"shift"?: Database["public"]['Enums']["route_shift"],"updated_at"?: string,"vehicle_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "routes_operator_id_fkey"
      columns: ["operator_id"]
isOneToOne: false
      referencedRelation: "operators"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "routes_school_id_operator_id_fkey"
      columns: ["school_id","operator_id"]
isOneToOne: false
      referencedRelation: "schools"
      referencedColumns: ["id","operator_id"]
    },{
      foreignKeyName: "routes_vehicle_id_operator_id_fkey"
      columns: ["vehicle_id","operator_id"]
isOneToOne: false
      referencedRelation: "vehicles"
      referencedColumns: ["id","operator_id"]
    }
                  ]
                },"schools": {
                  Row: {
                    "active": boolean,"created_at": string,"geofence_radius_m": number,"id": string,"location": unknown,"name": string,"operator_id": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"created_at"?: string,"geofence_radius_m"?: number,"id"?: string,"location": unknown,"name": string,"operator_id": string,"updated_at"?: string
                  }
                  Update: {
                    "active"?: boolean,"created_at"?: string,"geofence_radius_m"?: number,"id"?: string,"location"?: unknown,"name"?: string,"operator_id"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "schools_operator_id_fkey"
      columns: ["operator_id"]
isOneToOne: false
      referencedRelation: "operators"
      referencedColumns: ["id"]
    }
                  ]
                },"vehicles": {
                  Row: {
                    "active": boolean,"capacity": number,"created_at": string,"default_driver_id": string | null,"id": string,"operator_id": string,"plate": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "active"?: boolean,"capacity": number,"created_at"?: string,"default_driver_id"?: string | null,"id"?: string,"operator_id": string,"plate": string,"updated_at"?: string
                  }
                  Update: {
                    "active"?: boolean,"capacity"?: number,"created_at"?: string,"default_driver_id"?: string | null,"id"?: string,"operator_id"?: string,"plate"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "vehicles_default_driver_id_fkey"
      columns: ["default_driver_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "vehicles_operator_id_fkey"
      columns: ["operator_id"]
isOneToOne: false
      referencedRelation: "operators"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "_meta_wa_otp_body":
{ Args: { "otp": string,"phone": string,"template": string }; Returns: Json
                           },
"create_operator":
{ Args: { "country": string,"currency": string,"name": string,"timezone": string }; Returns: string
                           },
"send_sms_hook":
{ Args: { "event": Json }; Returns: Json
                           }
          }
          Enums: {
            "membership_role": "owner"|"driver"|"staff","route_shift": "am"|"pm"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "graphql_public": {
          Enums: {
            
          }
        },"public": {
          Enums: {
            "membership_role": ["owner", "driver", "staff"],"route_shift": ["am", "pm"]
          }
        }
} as const
