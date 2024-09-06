import dynamoDB from '../config/awsConfig';
import { User } from '../models/userModel';
import { 
  PutCommand, 
  GetCommand, 
  UpdateCommandInput,
  UpdateCommand, 
  DeleteCommand, 
  ScanCommand 
} from '@aws-sdk/lib-dynamodb';

const TABLE_NAME = 'Users';

// Create a new user
export const createUser = async (user: User): Promise<void> => {
  try {
    const params = {
      TableName: TABLE_NAME,
      Item: user,
    };
    await dynamoDB.send(new PutCommand(params));
  } catch (error) {
    console.error('Error creating user:', error);
    throw new Error('Error creating user');
  }
};

// Retrieve a user by ID
export const getUserById = async (id: string): Promise<User | null> => {
  try {
    const params = {
      TableName: TABLE_NAME,
      Key: { id },
    };
    const result = await dynamoDB.send(new GetCommand(params));
    return result.Item as User | null;
  } catch (error) {
    console.error('Error retrieving user by ID:', error);
    throw new Error('Error retrieving user by ID');
  }
};

// Update an existing user
export const updateUser = async (id: string, updateExpression: string, expressionAttributeValues: Record<string, any>): Promise<void> => {
  try {
    const params:UpdateCommandInput = {
      TableName: TABLE_NAME,
      Key: { id },
      UpdateExpression: updateExpression,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'UPDATED_NEW',
    };
    await dynamoDB.send(new UpdateCommand(params));
  } catch (error) {
    console.error('Error updating user:', error);
    throw new Error('Error updating user');
  }
};

// Delete a user by ID
export const deleteUser = async (id: string): Promise<void> => {
  try {
    const params = {
      TableName: TABLE_NAME,
      Key: { id },
    };
    await dynamoDB.send(new DeleteCommand(params));
  } catch (error) {
    console.error('Error deleting user:', error);
    throw new Error('Error deleting user');
  }
};

// Retrieve all users
export const getAllUsers = async (limit?: number,
  lastEvaluatedKey?: Record<string, any>
): Promise<{ users: User[]; lastEvaluatedKey?: Record<string, any> }> => {
  try {
    const params = {
      TableName: TABLE_NAME,
      Limit:limit,
      ExclusiveStartKey:lastEvaluatedKey
    };
    const result = await dynamoDB.send(new ScanCommand(params));
    return {
      users: result.Items as User[],
      lastEvaluatedKey: result.LastEvaluatedKey
    };
  } catch (error) {
    console.error('Error retrieving all users:', error);
    throw new Error('Error retrieving all users');
  }
};
